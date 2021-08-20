# aws-vault-tf

<img src="https://www.terraform.io/assets/images/og-image-8b3e4f7d.png" width="100" height="100" align="right" />  
<img  src="https://upload.wikimedia.org/wikipedia/commons/9/93/Amazon_Web_Services_Logo.svg"  width="100"  height="100"  alt="Powered by AWS Cloud Computing"  align="right"  >


### This is the Vault setup module for deploying vault in private EC2
This module will setup hashicorp vault in private EC2 in private subnet with a load balancer url. Backup of vault will be present in s3 bucket as provided in vault.hcl file under script folder. Tfstate will be stored in S3 bucket as provided in backend.tf


## Usage
 - This module has script folder which you can edit according to need
 - vault.service - To run vault as ubuntu service
 - vault.hcl - Custom configuration to use S3 as backup stratergy (IMPORTANT)
 - install.sh - Installation script to install vault
 - Create a `terrfaorm.tfvars` file by looking into the`terraform.tfvars.example` file 
 - Run `terraform init -backend-config=backend.tfvars` 
 - Run `terraform plan --var-file=terraform.tfvars` 
 - if all good then, run `terraform apply --var-file=terraform.tfvars`



## Access vault
There are 2 ways to interact with vault
 - Access through vault url present in DNS record
 - Access through vault CLI. 
 For this you need to SSH inside the private EC2 using public EC2 created through this module only.
 Use pem key present inside the public EC2 at home directory to ssh inside vault EC2.
 replace 'provide token' in VAULT_TOKEN env with the root token of vault inside the bashrc file (cmd to open bashrc = sudo nano ~/.bashrc)
 Finaly reload bashrc using cmd = . ~/.bashrc

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws_region | AWS Region where you want to deploy it | string | `"us-east-2"` | yes |
| access_key | AWS user access key, where you want to deploy infra | string | `""` | yes |
| secret_key | AWS user secret key for above mentioned key | string | `""` | yes |
| private_key_name | Private pem key file name | string | `""` | yes |
| public_key_name | Public pem key fine name | string | `""` | yes |
| private_name | Priavte EC2 name | string | `""` | yes |
| public_name | Public EC2 name | string | `""` | yes |
| aws_region_az | Private subnet region | string | `"b"` | yes |
| aws_public_region_az | Public subnet region | string | `"a"` | yes |
| instance_ami | EC2 ami id (ubuntu) | string | `"ami-00399ec92321828f5"` | yes |
| instance_type | EC2 type | string | `"t2.micro"` | yes |
| vpc_id | VPC Id where you want to deploy | string | `""` | yes |
| private_subnets | Private Subnets list | list(string) | `[]` | yes |
| public_subnets | Public Subnets list | list(string) | `[]` | yes |
| root_device_type | EC2 configuration | string | `"gp2"` | yes |
| root_device_size | EC2 configuration | string | `"50"` | yes |
| cert | Certificate id of existing DNS | string | `""` | yes |
| route53_zone_id | Existing DNS zone id  | string | `""` | yes |
| elb_name | Load balancer name | string | `""` | yes |
| elb_sg_name | Load balancer security group | string | `""` | yes |
| domain_prefix | Vault domain prefix e.g vault-ui | string | `""` | yes |


### How to integrate vault in terraform code and use it

Use below code to integrate vault in terraform code
```
 provider "vault" {
   version = "2.10.0"
   address         = var.vault_url
   skip_tls_verify = true
   token = var.token
 }
```

Use below code to use secrets from vault
```
 data "vault_generic_secret" "vault-test" {
   path = "kv/access_key"
 }
  data "vault_generic_secret" "vault-test1" {
   path = "kv/secret_key"
 }
```

Use below code to send secrets to vault
```
resource "vault_generic_secret" "example" {
  path = "kv/foo"
  data_json = <<EOT
{
    "foo":   "test",
    "abx": "xyz"
}
EOT
}
```


## TF State
tf State is stored in S3 bucket names S5-tfstate. Follow the steps while deploying new infra, the existing examples provide details of barebone-dev Environment. 
 - Create a file from `backend.tfvars.example` file named `backend.tfvars`. 
 - Update the `key = "global/aws-vault-tf"` to whatever ENV you are deploying `barebone-dev/global` accordingly

## Development 
We follow automation & security first, so the development process which need to be followed as below -
 - Create a branch out of `develop`, do the changes to module and do testing in `barebone-dev` which is out playground cluster
 - Once it is working fine without any manual changes then create a PR for it after running `tflint`
 - Once reviewer approved the PR, then merge to develop

