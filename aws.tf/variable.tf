variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "access_key" {
 type = string
 default = ""
}
 
variable "secret_key" {
 default = ""
}
 
variable "private_key_name" {
  description = "private pem key"
  type        = string
  default     = ""
}
variable "public_key_name" {
  description = "public pem key"
  type        = string
  default     = ""
}
 
variable "private_name" {
  description = "private instance name"
  type        = string
  default     = ""
}

variable "public_name" {
  description = "public instance name"
  type        = string
  default     = ""
}
 
variable "aws_region_az" {
  description = "AWS region availability zone"
  type        = string
  default     = "b"
}
variable "aws_public_region_az" {
  description = "AWS region availability zone"
  type        = string
  default     = "a"
}
 variable "instance_ami" {
  description = "ID of the AMI used"
  type        = string
  default     = "ami-00399ec92321828f5"
}
 
variable "instance_type" {
  description = "Type of the instance"
  type        = string
  default     = "t2.micro"
}
 
variable "root_device_type" {
  description = "Type of the root block device"
  type        = string
  default     = "gp2"
}
variable "root_device_size" {
  description = "Type of the root block device"
  type        = string
  default     = "50"
}
 
variable "private_subnet_id" {
  description = "private subnet id"
  type        = string
  default     = ""
}

variable "public_subnet_id" {
  description = "public subnet id"
  type        = string
  default     = ""
}
 
variable "vpc_id" {
  description = "vpc id"
  type        = string
  default     = ""
}

variable "cert" {
  description = "ssl cert for elb"
  type        = string
  default     = ""
}

variable "elb_name" {
  description = "elb name"
  type        = string
  default     = ""
}

variable "elb_sg_name" {
  description = "elb sg name"
  type        = string
  default     = ""
}

variable "domain_prefix" {
  description = "domain prefix"
  type        = string
  default     = ""
}


variable "route53_zone_id" {
  description = "route53 zone id"
  type        = string
  default     = ""
}