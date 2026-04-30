terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      configuration_aliases = [ aws.us_east_1 ]
    }
  }
}

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

# Registro para dominio e subdominio
resource "aws_route53_record" "frontend_record" {
   zone_id = aws_route53_zone.route53_zone.zone_id
   name = var.domain_name
   type = "A"
   alias {
      name = aws_cloudfront_distribution.cloudfront_dist.domain_name
      zone_id = aws_cloudfront_distribution.cloudfront_dist.hosted_zone_id
      evaluate_target_health = false
   }
} 

resource "aws_route53_record" "backend_record" {
   zone_id = aws_route53_zone.route53_zone.zone_id
   name = "api.${var.domain_name}"
   type = "A"
   alias {
      name = aws_cloudfront_distribution.cloudfront_dist.domain_name
      zone_id = aws_cloudfront_distribution.cloudfront_dist.hosted_zone_id
      evaluate_target_health = false
   }
} 
# Valida o certificado SSL
resource "aws_acm_certificate_validation" "cloudfront_cert_validation" {
   provider = aws.us_east_1
   certificate_arn = aws_acm_certificate.cloudfront_cert.arn # indica qual certificado SSL deve ser validado
   validation_record_fqdns = [for record in aws_route53_record.route53_record : record.fqdn] # indica quais registros DNS devem ser usados para validar o certificado SSL
}


# Cloudfront 
resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "s3_oac_${var.domain_name}"
  description                       = "Acesso seguro ao S3 do Frontend"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cloudfront_dist" {
   # Origem 1: Instancia EC2
   origin {
      domain_name = var.ec2_public_dns # Domínio público da instância EC2
      origin_id = "ec2-backend" # Identificador da origem
      custom_origin_config {
         http_port = 8080
         https_port = 443
         origin_protocol_policy = "http-only" # Política de protocolo para a origem (HTTP apenas)
         origin_ssl_protocols = ["TLSv1.2"]
      }
   }

  # Origem 2: Bucket S3 (Frontend) ---
   origin {
      domain_name              = var.s3_bucket_frontend 
      origin_id                = "s3-frontend"
      origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
   }

   enabled = true
   is_ipv6_enabled = true
   default_root_object = "index.html"
   aliases = [var.domain_name, "api.${var.domain_name}"] # Domínios personalizados para a distribuição CloudFront

   # Comportamento para API (api.codecraft.app.br)
   ordered_cache_behavior {
      target_origin_id = "ec2-backend" # Identificador da origem para a qual esse comportamento se aplica
      path_pattern = "/api/*"
      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods = ["GET", "HEAD"]

      # Repasse de Headers, Cookies e Query Strings para a origem, necessário para o funcionamento do JWT
      forwarded_values {
         query_string = true
         headers = ["*"] # Encaminha Content-Type, Authorization e outros cabeçalhos necessários para o funcionamento do JWT
         cookies {
            forward = "all" # Encaminha todos os cookies para a origem, necessário para o funcionamento do JWT
         }
      }

      viewer_protocol_policy = "redirect-to-https" # Força o uso de HTTPS
      min_ttl = 0 
      default_ttl = 0 
      max_ttl = 0 
   }

   # Comportamento padrão para o S3 (codecraft.app.br)
   default_cache_behavior {
      target_origin_id = "s3-frontend" # Identificador da origem
      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods = ["GET", "HEAD"]

      forwarded_values {
         query_string = false 
         headers      = []
         cookies {
            forward = "none"
         }
      }

      viewer_protocol_policy = "redirect-to-https" # Força o uso de HTTPS


      min_ttl = 0
      default_ttl = 3600 # 1h
      max_ttl = 86400 # 24h
   }

   # Configuração do Certificado SSL para a distribuição CloudFront
   viewer_certificate {
      acm_certificate_arn = aws_acm_certificate.cloudfront_cert.arn 
      ssl_support_method = "sni-only" # Método de suporte SSL (SNI apenas)
      minimum_protocol_version = "TLSv1.2_2021" # Versão mínima do protocolo TLS para conexões SSL
   }

   # Restrições de acesso para a distribuição CloudFront
   restrictions {
      geo_restriction {
         restriction_type = "none" # Sem restrições geográfias para acessar a distribuição CloudFront
      }
   }

   tags = {
      Project = "MyApp"
   }

}
