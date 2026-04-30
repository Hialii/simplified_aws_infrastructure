variable "domain_name" {
   description = "Domain name from Registro.br"
   type = string
}

variable "ec2_public_dns" {
   description = "Public DNS of the EC2 instance"
   type = string
}

variable "s3_bucket_frontend" {
   description = "Domain name of the S3 bucket for the frontend"
   type = string
}