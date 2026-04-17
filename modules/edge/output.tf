output "route53_name_servers" {
   description = "Name servers for the Route53 hosted zone"
   value = aws_route53_zone.route53_zone.name_servers
}

output "cloudfront_cert_arn" {
   description = "ARN of the ACM certificate for CloudFront"
   value = aws_acm_certificate.cloudfront_cert.arn
}