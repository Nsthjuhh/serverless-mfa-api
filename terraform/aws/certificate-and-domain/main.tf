
locals {
  full_domain_name = "${var.certificate_subdomain}.${var.cloudflare_zone_name}"
}

module "certificate" {
  source = "../acm-certificate"

  certificate_domain_name = local.full_domain_name
  cloudflare_zone_name    = var.cloudflare_zone_name
  create_dns_validation   = var.create_dns_validation
}

module "domain" {
  source = "../api-gateway-custom-domain"

  api_name        = var.api_name
  api_stage       = var.api_stage
  certificate_arn = module.certificate.certificate_arn
  domain_name     = local.full_domain_name
}
