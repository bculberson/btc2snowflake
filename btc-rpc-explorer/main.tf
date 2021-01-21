provider "aws" {
  region = "us-west-2"
}

resource "aws_ecr_repository" "explorer" {
  name                 = "explorer"
  image_tag_mutability = "MUTABLE"
}