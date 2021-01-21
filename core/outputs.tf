output "ec2ip" {
  value = aws_eip.ip.public_ip
}

output "corerpcuri" {
  value = aws_secretsmanager_secret_version.corerpc.secret_string
}

output "startup_script_bucket" {
  value = aws_s3_bucket_object.startup_script.bucket
}

output "snowflake_svc_public_key" {
  value = tls_private_key.svc_key.public_key_pem
}

output "snowflake_svc_private_key" {
  value = tls_private_key.svc_key.private_key_pem
}