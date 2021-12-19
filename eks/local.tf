locals {
  cluster_name = "${terraform.workspace}-eks-${random_string.suffix.result}"
}
