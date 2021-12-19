terraform {
  backend "s3" {
    bucket = "prod-3tier-app"
    encrypt = true
    key    = "infra.eks.tfstate"
    dynamodb_table = "tf-locks"
    region = "eu-west-1"
  }
}