# terraform_files/eks.tf

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.31.2"

  cluster_name    = "medicure-cluster"
  cluster_version = "1.27"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  # Mumbai AZs
  availability_zones = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]

  # Node group configuration
  node_groups = {
    medicure_nodes = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1

      instance_type    = "t3.medium"
      key_name         = "jenkins"  # make sure this key exists in Mumbai
    }
  }

  manage_aws_auth = true

  tags = {
    Environment = "dev"
    Project     = "medicure"
  }
}
