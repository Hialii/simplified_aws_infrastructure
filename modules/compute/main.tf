# Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
   most_recent = true
   owners = ["amazon"]

   filter {
      name = "name"
      values = ["al2023-ami-kernel-2023-x86_64"]
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
}
