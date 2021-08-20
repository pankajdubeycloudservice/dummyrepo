resource "tls_private_key" "pem" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "generated_key" {
  key_name   = var.private_key_name
  public_key = tls_private_key.pem.public_key_openssh
  provisioner "local-exec" { # Create "vaultserver.pem" on your machine!!
    command = "echo '${tls_private_key.pem.private_key_pem}' > ./${var.private_key_name}"
  }
  depends_on = [tls_private_key.pem]
}
resource "tls_private_key" "pem1" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "public_generated_key" {
  key_name   = var.public_key_name
  public_key = tls_private_key.pem1.public_key_openssh
  provisioner "local-exec" { # Create "s5vaultjumpbox.pem" on your machine!!
    command = "echo '${tls_private_key.pem1.private_key_pem}' > ./${var.public_key_name}"
  }
  depends_on = [tls_private_key.pem1]
}
resource "null_resource" "remove_pem_key" {
provisioner "local-exec" {
    command = "pwd && rm -rf ${path.module}/*.pem"
  } 
}

resource "aws_security_group" "allow-ssh" {
  vpc_id      = var.vpc_id
  name        = "vault-sg"
  description = "security group that allows ssh and all egress traffic"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "global"
  }
}

resource "aws_instance" "privateinstance" {
  ami                         = var.instance_ami
  availability_zone           = "${var.aws_region}${var.aws_region_az}"
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.allow-ssh.id]
  subnet_id                   = var.private_subnet_id
  key_name                    = aws_key_pair.generated_key.key_name
 
  root_block_device {
    delete_on_termination = true
    encrypted             = false
    volume_size           = var.root_device_size
    volume_type           = var.root_device_type
  }

  tags = {
    "Name"                = "global"
  }
  depends_on = [aws_security_group.allow-ssh]
}

resource "aws_instance" "publicinstance" {
  ami                         = var.instance_ami
  availability_zone           = "${var.aws_region}${var.aws_public_region_az}"
  instance_type               = var.instance_type
  #associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow-ssh.id]
  subnet_id                   = var.public_subnet_id
  key_name                    = aws_key_pair.public_generated_key.key_name
 
  root_block_device {
    delete_on_termination = true
    encrypted             = false
    volume_size           = var.root_device_size
    volume_type           = var.root_device_type
  }

  tags = {
    Name = "global"
  }
  depends_on = [aws_security_group.allow-ssh]
}


resource "null_resource" "ec2-ssh-connection" {
  connection {
              host                  = aws_instance.publicinstance.public_ip
              type                  = "ssh"
              port                  = 22
              user                  = "ubuntu"
              private_key           = tls_private_key.pem1.private_key_pem
              timeout               = "3m"
              agent                 = false              
  }
 
  provisioner "file" {
    source      = "${path.module}/scripts/install.sh"
    destination = "install.sh"
  }
  provisioner "file" {
    source      = "${path.module}/scripts/vault.service"
    destination = "vault.service"
  }
  provisioner "file" {
    source      = "${path.module}/scripts/vault.hcl"
    destination = "vault.hcl"
  }
  provisioner "file" {
    source      = "${path.module}/${var.private_key_name}"
    destination = "vaultKey.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x install.sh",
      "chmod 400 vaultKey.pem",
      "scp -p -o StrictHostKeyChecking=no -i 'vaultKey.pem' vault.hcl vault.service install.sh ubuntu@${aws_instance.privateinstance.private_ip}:/home/ubuntu",
      "ssh -o StrictHostKeyChecking=no -i 'vaultKey.pem' ubuntu@${aws_instance.privateinstance.private_ip} 'sudo bash /home/ubuntu/install.sh'"
    ]
  }
  depends_on = [aws_instance.publicinstance, aws_instance.publicinstance]
}

resource "aws_elb" "vault-elb" {
  name               = var.elb_name
  security_groups = [aws_security_group.vault-sg.id]
  subnets = [var.public_subnet_id, var.private_subnet_id]

  listener {
    instance_port      = 8200
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = var.cert
                        
  }

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 2
    timeout             = 5
    target              = "TCP:8200"
    interval            = 30
  }

  instances                   = [aws_instance.privateinstance.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "global"
  }
  depends_on = [aws_security_group.vault-sg, aws_instance.privateinstance]
}

resource "aws_security_group" "vault-sg" {
  name        = var.elb_sg_name
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

   ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "global"
  }
}


resource "aws_route53_record" "s5vault" {
  zone_id = var.route53_zone_id
  name    = var.domain_prefix
  type    = "A"

  alias {
    name                   = aws_elb.vault-elb.dns_name
    zone_id                = aws_elb.vault-elb.zone_id
    evaluate_target_health = true
  }
  depends_on = [aws_elb.vault-elb]
}