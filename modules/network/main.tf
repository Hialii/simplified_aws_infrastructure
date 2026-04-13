resource "aws_vpc" "main-vpc" {
   cidr_block = var.base_cidr_block

   tags = {
      Name = "main-vpc"
   }
}

resource "aws_subnet" "public-subnet" {
   count = length(var.availability_zone)

   vpc_id = aws_vpc.main-vpc.id
   cidr_block = var.subnet_public_cidr[count.index]
   availability_zone = var.availability_zone[count.index]

   tags = {
      Name = "public-subnet-${count.index}"
   }
}

resource "aws_internet_gateway" "main-igw" {
   vpc_id = aws_vpc.main-vpc.id

   tags = {
      Name = "main-igw"
   }
}

resource "aws_route_table" "main-route-table" {
   vpc_id = aws_vpc.main-vpc.id

   route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.main-igw.id
   }

   tags = {
      Name = "route-table-main"
   }
}

resource "aws_route_table_association" "main-route-table-association" {
   count = length(var.availability_zone)

   subnet_id = aws_subnet.public-subnet[count.index].id
   route_table_id = aws_route_table.main-route-table.id
}

# Subnets privadas para o RDS
resource "aws_subnet" "rds-private-subnet" {
   count = length(var.availability_zone) 

   vpc_id = aws_vpc.main-vpc.id
   cidr_block = var.subnet_private_cidr[count.index]
   availability_zone = var.availability_zone[count.index]

   tags = {
      Name = "rds-private-subnet-${count.index}"
   }
}

resource "aws_route_table" "rds-route-table"{
   vpc_id = aws_vpc.main-vpc.id

   tags = {
      Name = "route-table-rds"
   }
}

resource "aws_route_table_association" "rds-route-table-association" {
   count = length(var.availability_zone) 

   subnet_id = aws_subnet.rds-private-subnet[count.index].id
   route_table_id = aws_route_table.rds-route-table.id
}

# Endpoint para o S3
resource "aws_vpc_endpoint" "s3-endpoint" {
   vpc_id = aws_vpc.main-vpc.id
   service_name = "com.amazonaws.${var.s3_region}.s3"
   route_table_ids = aws_route_table.main-route-table.id
}