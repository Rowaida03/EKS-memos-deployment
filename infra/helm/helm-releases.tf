resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  repository       = "oci://quay.io/jetstack/charts"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = "v1.21.1"

  values = [
    templatefile("${path.module}/helm/cert-manager-values.yaml", {
      role_arn = module.cert_manager_irsa_role.iam_role_arn
    })
  ]
}

resource "helm_release" "external-dns" {
  name             = "external-dns"
  repository       = "https://kubernetes-sigs.github.io/external-dns/"
  chart            = "external-dns"
  namespace        = "external-dns"
  create_namespace = true

  values = [
    templatefile("${path.module}/helm/external-dns-values.yaml", {
      role_arn = module.external_dns_irsa_role.iam_role_arn
    })
  ]
}

resource "helm_release" "traefik" {
  name             = "traefik"
  repository       = "https://traefik.github.io/charts"
  chart            = "traefik"
  namespace        = "traefik"
  create_namespace = true

  values = [
    file("${path.module}/helm/traefik-values.yaml")
  ]
}