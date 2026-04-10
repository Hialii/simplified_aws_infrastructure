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
}