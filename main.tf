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

module "compute" {
   source = "./modules/compute"
   ec2_subnet_id = module.network.public_subnets_id[0]
   sg_web_ec2_id = module.security.sg_web_ec2_id
   ec2_instance_profile = module.security.ec2_iam_profile_name
   ec2_key_pair_name = var.ec2_key_pair_name
}

module "edge" {
   source = "./modules/edge"
   domain_name = var.domain_name
   ec2_public_dns = module.compute.ec2_public_dns

   providers = {
      aws.us_east_1 = aws.us_east_1 # Nome dentro do módulo = nome no provedor global
   }
}