# output "private_pem_key" {
#   description = "pem_key"
#   value       = tls_private_key.pem.private_key_pem
# }
# output "public_pem_key" {
#   description = "pem_key"
#   value       = tls_private_key.pem1.public_key_pem
# }
# output "public_key_openssh" {
#   description = "pem_key"
#   value       = tls_private_key.pem.public_key_openssh
# }
# output "public_key_fingerprint_md5" {
#   description = "pem_key"
#   value       = tls_private_key.pem.public_key_fingerprint_md5
# }

# output "key_pair_id" {
#   description = "key_pair_pem"
#   value       = aws_key_pair.generated_key.key_pair_id
# }

# output "key_pair_pem" {
#   description = "key_pair_pem"
#   value       = aws_key_pair.generated_key.public_key
# }

output "ec2_private_ip" {
  description = "ec2(private-instance)_private_ip"
  value       = aws_instance.privateinstance.private_ip 
}

output "ec2_public_ip" {
  description = "ec2(public-instance)_private_ip"
  value       = aws_instance.publicinstance.public_ip 
}

output "vault-url" {
  description = "url to connect to vault"
  value       = aws_route53_record.s5vault.fqdn
}