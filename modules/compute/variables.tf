variable "ec2_instance_type" {
   description = "EC2 instance type"
   type = string
   default = "t3.micro"
}

variable "ec2_subnet_id" {
   description = "Subnet ID for EC2 instance"
   type = string
}

variable "sg_web_ec2_id" {
   description = "Security Group for EC2 instance"
   type = string
}

variable "ec2_key_pair_name" {
   description = "Key pair name fo EC2 instance"
   type = string 
}

variable "ec2_instance_profile" {
   description = "IAM Instance Profile for EC2 instance"
   type = string
}


