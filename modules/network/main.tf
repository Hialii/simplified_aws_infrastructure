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