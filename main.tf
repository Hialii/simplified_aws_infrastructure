terraform {
   required_providers {
      aws = {
         source = "hashicorp/aws"
         version = "~> 5.0"
      }
   }

   required_version = ">= 1.6"
}

provider "aws" {
   region = "us-east-2"
}

module "network" {
   source = "./modules/network"
   base_cidr_block = "10.0.0.0/16"
   availability_zone = ["us-east-2a", "us-east-2b"]
   subnet_public_cidr = ["10.0.1.0/24", "10.0.2.0/24"]
   subnet_private_cidr = ["10.0.3.0/24", "10.0.4.0/24"]
   s3_region = "us-east-2"
}

module "security" {
   source = "./modules/security"
   my_ip = var.my_ip
   vpc_id = module.network.vpc_id
}

module "data" {
   source = "./modules/data"
   rds_sg = module.security.sg_rds_id
   db_username = var.db_username
   db_password = var.db_password
   rds_private_subnet_ids = module.network.rds_private_subnets_id
}