module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 18.0"
  cluster_name    = local.cluster_name

  cluster_version = "1.22"
  subnet_ids      = module.vpc.private_subnets

  cluster_endpoint_private_access  = true

  vpc_id = module.vpc.vpc_id
  
  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  manage_aws_auth_configmap = true

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::970247663978:user/jenkins"
      username = "jenkins"
      groups   = ["system:masters"] },
  ]

  eks_managed_node_groups = {
    managed_node = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t3.large", "t2.medium"]
      capacity_type  = "SPOT"
    }
  }

  tags = {
    Environment = "${terraform.workspace}-eks"
    Terraform   = "true"    
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
