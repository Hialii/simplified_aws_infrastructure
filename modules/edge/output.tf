output "route53_name_servers" {
   description = "Name servers for the Route53 hosted zone"
   value = aws_route53_zone.route53_zone.name_servers
}