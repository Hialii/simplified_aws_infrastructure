# Securiry group da EC2
resource "aws_security_group" "sg-web-ec2" {
   name = "sg-web"
   description = "Security group for web server"
   vpc_id = aws_vpc.main-vpc.id
} 

# lista de prefixos do cloudfront 
data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

# regra de entrada para permitir tráfego do Cloufront para a porta 8080 da EC2
resource "aws_vpc_security_group_ingress_rule" "ec2-cloudfront-ingress-rule" {
   security_group_id = security_group.sg-web-ec2.id
   prefix_list_id = data.aws_ec2_managed_prefix_list.cloudfront.id
   from_port = 8080
   to_port = 8080
   ip_protocol = "tcp"
}

# regra de entrada para permitir tráfego do meu IP para a porta 22 (ssh) da EC2
resource "aws_vpc_security_group_ingress_rule" "ec2-ssh-ingress-rule" {
   security_group_id = security_group.sg-web-ec2.id
   cidr_ipv4 =  var.my_ip
   from_port = 22
   to_port = 22
   ip_protocol = "tcp"
} 

# regra de saída para permitir tráfego da EC2 para qualquer destino
resource "aws_vpc_security_group_egress_rule" "ec2-egress-rule" {
   security_group_id = security_group.sg-web-ec2.id
   cidr_ipv4 = "0.0.0.0/0"
   ip_protocol = "-1" # qualquer protocolo
}  


# Security group para RDS
resource "security_group" "sg-rds" {
   name = "sg-rds"
   description = "Security group for RDS"
   vpc_id = aws_vpc.main-vpc.id
} 

# regra de entrada para permitir tráfego da EC2 para a porta 5432 do RDS
resource "aws_vpc_security_group_ingress_rule" "rds-ec2-ingress-rule" {
   security_group_id = security_group.sg-rds.id
   from_port = 5432
   to_port = 5432
   ip_protocol = "tcp"
   referenced_security_group_id = aws_security_group.sg-web-ec2.id
}

# IAM Role para EC2
resource "aws_iam_role" "ec2-role" {
   name = ec2-role
   
   # Politica de confiança para permitir que a EC2 assuma a role
   assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
         {
            Effect = "Allow"
            Principal = {
               Service = ec2.amazonaws.com
            }
         }
      ]
   })
}

# Politica com as permissões da EC2
resource "aws_iam_role_policy" "ec2-policy" {
   name= "ec2-policy"
   role = aws_iam.role.ec2-role.id

   policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
         {
            Effect = "Allow"
            Action = [
               s3:GetObject,
               s3:PutObject,
               ssm:GetParameter,
               ssm:GetParameters,
            ]
            Resource = "*"
         }
      ]
   })
}

# instance profile para associar a role a EC2
resource "aws_iam_instance_profile" "ec2-intance-profile" {
   name = "ec2-instance-rofile"
   role = aws_iam_role.ec2-role.name
}