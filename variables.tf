variable "my_ip" {
  description = "Your IP address in CIDR format /32"
  type      = string
  sensitive = true
}

variable "db_username" {
   description = "Username for RDS database"
   type = string
   sensitive = true
}

variable "db_password" {
   description = "Password for RDS database"
   type = string
   sensitive = true
}

