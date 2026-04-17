# Route53
resource "aws_route53_zone" "route53_zone" {
   name = var.domain_name
}

# Solitar certificdo SSL para o CloudFront
resource "aws_acm_certificate" "cloudfront_cert" {
   provider = aws.us_east_1
   domain_name = var.domain_name
   validation_method = "DNS"
   subject_alternative_names = ["*.${var.domain_name}"]

   lifecycle {
      create_before_destroy = true
   }
}

# Cria os registros DNS para validar o certificado SSL
resource "aws_route53_record" "route53_record" {
   for_each = { # Cria um registro DNS para cada dominio a ser validado
      for dvo in aws_acm_certificate.cloudfront_cert.domain_validation_options : dvo.domain_name => { 
         name = dvo.resource_record_name
         type = dvo.resource_record_type
         value = dvo.resource_record_value
      }
   }
   allow_overwrite = true # Sobrescreve os registros DNS de validação do certificado SSL, caso eles já existam
   name = each.value.name # Nome do registro DNS para validar o certificado SSL
   type = each.value.type # Tipo do registro DNS para validar o certificado SSL 
   records = [each.value.value] # Valor do registro DNS para validar o certificado SSL
   ttl= 60 
   zone_id = aws_route53_zone.route53_zone.zone_id # indica qual zona do Route53 deve ser usada para criar os registros de validação do certificado SSL
}

# Valida o certificado SSL
resource "aws_acm_certificate_validation" "cloudfront_cert_validation" {
   provider = aws.us_east_1
   certificate_arn = aws_acm_certificate.cloudfront_cert.arn # indica qual certificado SSL deve ser validado
   validation_record_fqdns = [for record in aws_route53_record.route53_record : record.fqdn] # indica quais registros DNS devem ser usados para validar o certificado SSL
}
