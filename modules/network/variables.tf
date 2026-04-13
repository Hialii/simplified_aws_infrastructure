variable "base_cidr_block" {
   description = "CIDR block for VPC"
   type = string
}

variable "availability_zone" {
   description = "List of availability zones"
   type = list(string)
}

variable "subnet_public_cidr" {
   description = "CIDR block for public subnet"
   type = list(string)
}

variable "subnet_private_cidr" {
   description = "CIDR block for public subnet"
   type = list(string)
}

variable "s3_region" {
   description = "Region for S3 bucket"
   type = string
}