terraform {
  backend "s3" {
    bucket = "prod-3tier-app"
    encrypt = true
    key    = "infra.jenkins.tfstate"
    region = "eu-west-1"
  }
}