output "sg_web_ec2_id" {
  description = "Security Group ID for EC2 instances"
  value       = aws_security_group.sg-web-ec2.id
}

output "sg_rds_id" {
  description = "Security Group ID for RDS instances"
  value       = aws_security_group.sg-rds.id
}

output "ec2_iam_profile_name" {
  description = "Instance Profile Name for EC2 instances"
  value       = aws_iam_instance_profile.ec2_profile.name
}