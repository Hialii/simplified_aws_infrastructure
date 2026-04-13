output "vpc_id" {
   description = "ID of the VPC"
   value = aws_vpc.main-vpc.id
}

output "public_subnets_id" {
   description = "IDs of the public subnets"
   value = aws_subnet.public-subnet[*].id
}

output "rds_private_subnets_id" {
   description = "IDs of the private subnets"
   value = aws_subnet.rds-private-subnet[*].id
}

output "internet_gateway_id" {
   description = "ID of the Internet Gateway"
   value = aws_internet_gateway.main-igw.id
}

output "endpoint_vpc_s3" {
   description = "Endpoint for S3 in the VPC"
   value = aws_vpc_endpoint.s3-endpoint.id
}