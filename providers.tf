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

# Provider usado para criar o ACM Certificate, necessário para o Cloudfront
provider "aws" {
   alias = "us_east_1"
   region = "us-east-1"
}
