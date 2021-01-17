resource "aws_ecr_repository" "rpc2stage" {
  name                 = "rpc2stage"
  image_tag_mutability = "MUTABLE"
}

output "repository_url" {
  value = aws_ecr_repository.rpc2stage.repository_url
}