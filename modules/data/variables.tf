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

variable "rds_sg" {
   description = "Security group ID for RDS"
   type = string
}

variable "rds_private_subnet_ids" {
   description = "List of private subnet IDs for RDS"
   type = list(string)
}