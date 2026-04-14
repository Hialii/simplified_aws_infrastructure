variable "my_ip" {
   description = "Your IP address in CIDR format"
   type = string
   sensitive = true
}

variable "vpc_id" {
   description = "ID of the VPC"
   type = string
}

