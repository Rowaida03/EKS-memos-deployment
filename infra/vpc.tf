module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "6.6.1"

  name = local.name
  cidr = "10.0.0.0/16"

  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_dns_hostnames = true 

public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared" # Your ALB living in a public subnet ↔ same role as the elb-tagged public subnet here.
    "kubernetes.io/role/elb" = 1
}

private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared" # Your route table connecting things to the private subnet ↔ same role as the internal-elb-tagged private subnet here,
    "kubernetes.io/role/internal-elb" = 1
}

  tags =  local.tags
}