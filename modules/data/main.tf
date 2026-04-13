# RDS Subnet Group
resource "aws_db_subnet_group" "rds-subnet-group" {
   name = "rds-subnet-group"
   subnet_ids = var.rds_private_subnet_ids

   tags = {
      Name = "rds-subnet-group"
   }
}

# RDS Instance
resource "aws_db_instance" "rds-database" {
   allocated_storage = 20 
   db_name = "rds_database"
   engine = "postgres"
   engine_version = "16"
   instance_class = "db.t3.micro"

   # Credenciais de acesso
   username = var.db_username
   password = var.db_password
   
   # Configurações de rede e segurança
   vpc_security_group_ids = [var.rds_sg]
   db_subnet_group_name = aws_db_subnet_group.rds-subnet-group.name
   skip_final_snapshot = true
   publicly_accessible = false # RDS não será acessível publicamente somente pela EC2
   multi_az = false 

   tags = {
      Name = "main-rds"
   }
}
