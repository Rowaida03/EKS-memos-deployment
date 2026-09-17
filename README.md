# Memos on EKS; A cloud-native deployment ******

A production style deployment of memos, an open-source note taking application, on Amazon EKS, built with Terraform, secured with IRSA, exposed via Traefik + the AWS Load Balancer Controller, automatically issued a TLS certificate via cert-manager, given a live domain via external-dns/Route53, deployed through GitOps with ArgoCD, and observed with Prometheus/Grafana. CI/CD is handled by two GitHub Actions pipelines using OIDC.

## Memos running on EKS
![Memos running on EKS](images/memos-application.png)

## Running this locally
Everything in infra/ and kubernetes/ targets a real EKS cluster, but the app itself can be run entirely on your own machine with just Docker.

### Option A - plain Docker
'''
docker build -t memos-local -f Dockerfile .
docker run -d --name memos -p 5230:5230 -v ~/.memos:/var/opt/memos
'''
Then open http://localhost:5230 and create the admin account.

 The -v flag persists your data in ~/.memos on your host, so it survives container restarts (unlike the ephemeral setup used on EKS in this project. See tradeoffs).  *****!!!make it tap

### Option B - Local Kubernetes (Kind, Minikube, Orbstack etc):

 INSERT THE RELEVANT CODE HERE !!!!!!

## Table of contents

- Architecture 
- Tech stack
- Repository layout
- Infrastructure 
- Kubernetes add-ons
- Application deployment
- GitOps (ArgoCD)
- CI/CD pipelines
- Monitoring 
- Key decisions and tradeoffs
- Problems faced & solutions
- Known limitations/ improvements to be made

### Architecture diagram

![Architecture diagram](images/Memos_eks.drawio.png)

**Request flow**: Browser→Route53(DNS)→NLB→Traefik Ingress→memos-svc→memos-deployment pods. TLS is terminated by traefik using a certificate issued by cert-manager via Let's Encrypt (DNS-01 challenge through Route53).


### Tech Stack

| Layer | Tool | Why |
|---|---|---|
| IaC | Terraform (`terraform-aws-modules/vpc`, `.../eks`, `.../iam`) | Reusable, well-maintained community modules |
| Container orchestration | Amazon EKS 1.33 | Managed control plane |
| Ingress | Traefik | Routes incoming HTTP/S traffic to the right Kubernetes Service |
| Load balancing | AWS Load Balancer Controller (NLB) | Provisions and manages the real AWS load balancer that sits in front of Traefik, exposing it to the internet |
| TLS | cert-manager + Let's Encrypt | Free, auto-renewing certs, DNS-01 challenge via Route53 |
| DNS | external-dns + Route53 | Ingress changes automatically create/update DNS records |
| IAM for pods | IRSA (IAM Roles for Service Accounts) | Least-privilege AWS access per component, no static credentials in-cluster |
| GitOps | ArgoCD | Cluster state reconciled from Git |
| CI/CD | GitHub Actions + OIDC | No long-lived AWS access keys stored as secrets |
| Image scanning | Trivy | Vulnerability scanning of the built image before push |
| IaC scanning | Checkov | Static analysis of Terraform for misconfigurations |
| Registry | Amazon ECR | Private, IAM-authenticated registry integrated with EKS |
| Monitoring | kube-prometheus-stack (Prometheus + Grafana) | Cluster and workload metrics, pre-built dashboards |
| App | [usememos/memos](https://github.com/usememos/memos) | Self-hosted note-taking app, SQLite-backed |


## Repository layout

```
.
├── .github/workflows/
│   ├── terraform.yml              # Pipeline 1: scan, validate, plan, apply infra
│   └── build-deploy-ecr.yaml      # Pipeline 2: build, scan, push image, deploy
├── infra/                         # Terraform root module
│   ├── vpc.tf
│   ├── eks.tf
│   ├── ecr.tf
│   ├── irsa.tf                    # cert-manager / external-dns / LB controller IRSA roles
│   ├── github-oidc.tf             # GitHub OIDC provider + CI role
│   ├── helm-releases.tf           # Traefik, cert-manager, external-dns, ALB controller,
│   │                              # ArgoCD, kube-prometheus-stack
│   ├── helm/                      # values.yaml files for each Helm release
│   ├── locals.tf
│   ├── backend.tf
│   └── providers.tf
├── kubernetes/                    # Plain manifests, synced by ArgoCD
│   ├── memos-deployment.yaml
│   ├── memos-ingress.yaml
│   ├── cluster-issuer.yaml
│   └── argocd-app.yaml
├── memos/                         # Application source (usememos/memos)
├── bootstrap/                     # One-time Terraform state backend (S3 + native locking)
├── images/                        # Diagrams and screenshots for this README
└── dockerfile                     # Multi-stage build for the memos image
```

### Infrastructure (Terraform)

#### VPC

- terraform-aws-modules/vpc/aws, 3 AZs, public + private subnets.
- Single NAT gateway - see tradeoffs below !!!!! make that underlined
- Public subnets tagged 'kubernetes.io/role/elb', private tagged 'kubernetes.io/role/internal-elb', both tagged 'kubernetes.io/cluster/<cluster-name>' - required for automatic load balancer subnet discovery. 








# Workflows

![Terraform workflow](images/terraform-workflow.png)

![Build and Push Workflow](images/build-scan-push-workflow.png)

# Dashboards

![ArgoCD](images/argocd-health.png)

![Grafana](images/grafana-metrics.png)


