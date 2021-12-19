variable "AWS_REGION" {
  default = "eu-west-1"
}
variable "PATH_TO_PRIVATE_KEY" {
  default = "~/.ssh/id_rsa"
}
variable "PATH_TO_PUBLIC_KEY" {
  default = "~/.ssh/id_rsa.pub"
}
variable "AMIS" {
  type = map(string)
  default = {
    us-east-1 = "ami-0f9cf087c1f27d9b1"
    us-west-2 = "ami-0653e888ec96eab9b"
    eu-west-1 = "ami-08ca3fed11864d6bb"
  }
}
variable "INSTANCE_DEVICE_NAME" {
  default = "/dev/xvdh"
}

variable "TERRAFORM_VERSION" {
  default = "1.0.8"
}

