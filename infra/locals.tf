locals {
    name = "eks"
    domain = "rowaida.memos.co.uk"
    region = "eu-west-2" # London region


    tags = {
        Environment = "dev"
        Application = "memos"
        Project = "eks-memos"
        Owner = "rowaida"
        Terraform = "true"
    }

    cluster_name = "eks-cluster"
}