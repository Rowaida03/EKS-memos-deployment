# IAM roles for service accounts

# Cert manager IRSA 
module "cert_manager_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"

  name                          = "cert-manager"
  attach_cert_manager_policy    = true
  cert_manager_hosted_zone_arns = ["your website to be hosted zone arn"]

  oidc_providers = {
    eks = {
      provider_arn               = module.eks.oidc_providers_arn
      namespace_service_accounts = ["cert-manager:cert-manager"] # namespace:service 
    }
  }

  tags = local.tags
}

## External DNS IRSA

module "external_dns_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"

  name                          = "external-dns"
  attach_external_dns_policy    = true
  external_dns_hosted_zone_arns = ["your website to be hosted zone arn"]

  oidc_providers = {
    eks = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["external-dns:external-dns"]
    }
  }
}



