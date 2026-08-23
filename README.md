# Memos on EKS; A cloud-native deployment 

A production style deployment of memos on Amazon EKS, built with Terraform, secured with IRSA, exposed via Traefik + the AWS Load Balancer Controller, automatically issued a TLS certificate via cert-manager, given a live domain via external-dns/Route53, deployed through GitOps with ArgoCD, and observed with Prometheus/Grafana. CI/CD is handled by two GitHub Actions pipelines using OIDC.

## What is Memos?

Memos is an open-source note-taking app 

