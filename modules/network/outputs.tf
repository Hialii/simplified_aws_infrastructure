output "vpc-id" {
   value = aws_vpc.main-vpc.id
}

output "pubic-subnets-id" {
   value = aws_subnet.public-subnet[*].id
}

output "internet-gateway-id" {
   value = aws_internet_gateway.main-igw.id
}