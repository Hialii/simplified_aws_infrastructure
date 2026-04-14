# Network module outputs
output "vpc-id" {
   description = "ID of the VPC"
   value = module.network.vpc_id
}

output "public-subnets-id" {
   description = "IDs of the public subnets"
   value = module.network.public_subnets_id
}

output "rds-private-subnets-id" {
   description = "IDs of the private subnets"
   value =  module.network.rds_private_subnets_id
}

output "internet-gateway-id" {
   description = "ID of the Internet Gateway"
   value =  module.network.internet_gateway_id
}

# Security module outputs
output "sg_web_ec2_id" {
  description = "Security Group ID for EC2 instances"
  value       = module.security.sg_web_ec2_id
}

output "sg_rds_id" {
  description = "Security Group ID for RDS instances"
  value       = module.security.sg_rds_id
}

output "ec2_iam_profile_name" {
  description = "Instance Profile Name for EC2 instances"
  value       = module.security.ec2_iam_profile_name
}

output "rds_endpoint" {
  description = "Endpoint of the RDS instance"
  value = module.data.rds_endpoint
}

output "endpoint_vpc_s3" {
   description = "Endpoint for S3 in the VPC"
   value = module.network.endpoint_vpc_s3
}

output "ec2_public_ip" {
   description = "Public IP address of the EC2 instance"
   value = module.compute.ec2_public_ip
}

output "ec2_instance_id" {
   description = "ID of the EC2 instance"
   value = module.compute.ec2_instance_id 
}