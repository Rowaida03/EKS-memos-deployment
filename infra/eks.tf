module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = local.cluster_name
  kubernetes_version = "1.33"


  enable_irsa = true

  endpoint_public_access = true # your control planes api server is now accessible over https, the public internetaccess_entries. it now has a public endpoint 
  # restrict to your own ip 
  endpoint_private_access = true # the api server is also reachable from inside the VPC 

  vpc_id                   = module.vpc.id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.public_subnets

  eks_managed_node_groups = { # defining the ec2 worker nodes that will run your pods
    workers = {
      disk_size      = 50 # ebs volume size - the local disk storage of each worker node
      instance_types = ["t3a.large", "t3.large"]

      min_size     = 2
      max_size     = 6
      desired_size = 2

    }

  }

  tags = local.tags
}
