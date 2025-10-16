# eks.tf
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.31.2"

  cluster_name    = "medicure-cluster"
  cluster_version = "1.27"

  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  node_groups = {
    medicure_nodes = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1

      instance_type    = "t3.medium"
    }
  }

  tags = {
    Name = "medicure-cluster"
  }
}
