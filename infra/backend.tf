terraform {
  backend "s3" {
    bucket       = "rowaida-eks-tf-state-bucket"
    key          = "infra/terraform.tfstate" # this is the path of the statefile inside the s3 bucket 
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true # prevents overwritting and clashes 
  }
}