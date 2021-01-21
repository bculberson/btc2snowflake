provider "aws" {
  region = "us-west-2"
}

resource "aws_ecr_repository" "rpc2stage" {
  name                 = "rpc2stage"
  image_tag_mutability = "MUTABLE"
}