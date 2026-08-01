terraform {
  backend "s3" {
    bucket       = "rowaida-eks-tf-state-bucket"
    key          = "infra/terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
}