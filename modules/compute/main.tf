# Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
   most_recent = true
   owners = ["amazon"]

   filter {
      name = "name"
      values = ["al2023-ami-2023.*-x86_64"]
   }

   filter {
      name = "virtualization-type"
      values = ["hvm"]
   }
} 

# EC2 Instance
resource "aws_instance" "web-server" {
   ami = data.aws_ami.amazon_linux_2023.id
   instance_type = var.ec2_instance_type
   subnet_id = var.ec2_subnet_id
   vpc_security_group_ids = [var.sg_web_ec2_id]
   key_name = var.ec2_key_pair_name
   iam_instance_profile = var.ec2_instance_profile

   tags = {
      Name = "ec2-web-server"
   }

   user_data = <<-EOF
#!/bin/bash 
# atualiza o sistem e instala o Docker
dnf update -y
dnf install -y docker

# inicia o serviço Docker 
systemctl start docker
systemctl enable docker

# adiciona usuário ec2-user ao grupo docker para permitir a execução de comandos Docker sem sudo
usermod -aG docker ec2-user

# instala docker-compose 
mkdir -p /usr/local/lib/docker/cli-plugins 
curl -SL https://github.com/docker/compose/releases/download/v2.24.1/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# busca variáveis de ambiente do SSM Parameter Store 
REGION='us-east-2'
DB_ENDPOINT=$(aws ssm get-parameter --name "/backend/rds/endpoint" --region $REGION --query "Parameter.Value" --output text)
DB_USERNAME=$(aws ssm get-parameter --name "/backend/rds/username" --region $REGION --query "Parameter.Value" --output text)
BD_PASSWORD=$(aws ssm get-parameter --name "/backend/rds/password" --region $REGION --with-decryption --query "Parameter.Value" --output text)

# cria arquivo .env com as variáveis de ambiente para a aplicação
cat <<EOT > /home/ec2-user/.env
DB_ENDPOINT=$DB_ENDPOINT
DB_USERNAME=$DB_USERNAME
DB_PASSWORD=$DB_PASSWORD
EOT

# muda a propriedade do arquivo .env para o usuário ec2-user
chown ec2-user:ec2-user /home/ec2-user/.env

# log para conferir se o script foi inicializado corretamente
echo "Script de inicialização da EC2 executado com sucesso em $(date)" > /home/ec2-user/log/user_data_sucess.log 
EOF

}
