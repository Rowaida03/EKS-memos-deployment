resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  repository       = "oci://quay.io/jetstack/charts"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = "v1.21.1"

  values = [
    templatefile("${path.module}/helm/cert-manager-values.yaml", {
      role_arn = module.cert_manager_irsa_role.arn
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
      role_arn = module.external_dns_irsa_role.arn
    })
  ]
}

resource "helm_release" "traefik" {
  name             = "traefik"
  repository       = "https://traefik.github.io/charts"
  chart            = "traefik"
  namespace        = "traefik"
  create_namespace = true
  depends_on       = [helm_release.aws_load_balancer_controller]

  values = [
    file("${path.module}/helm/traefik-values.yaml")
  ]
}


resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set = [
    {
      name  = "clusterName"
      value = "eks-cluster"
    },

    {
      name  = "vpcId"
      value = module.vpc.vpc_id
    },
    {
      name  = "serviceAccount.create"
      value = "true"
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = module.lb_controller_irsa_role.arn
    }
  ]
}