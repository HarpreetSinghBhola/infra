module "container_eks-aws-auth" {
  source  = "tedilabs/container/aws//modules/eks-aws-auth"
  version = "0.13.0"

  map_users = [{
    iam_user = "arn:aws:iam::970247663978:user/hsingh"
    username = "hsingh"
    groups   = ["arn:aws:iam::970247663978:group/DevOps"]
  }]
}

