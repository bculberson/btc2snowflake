resource "aws_ecr_repository" "rpc2stage" {
  name                 = "rpc2stage"
  image_tag_mutability = "MUTABLE"
}

resource "aws_s3_bucket" "data" {
  bucket = "btc2snowflake-rpc2stage"
  acl    = "private"
}

resource "aws_s3_bucket_object" "startup_script" {
  key    = "start.sh"
  bucket = aws_s3_bucket.data.id
  source = "start.sh"
}

output "repository_url" {
  value = aws_ecr_repository.rpc2stage.repository_url
}

output "start_bucket" {
  value = aws_s3_bucket_object.startup_script.bucket
}