provider "aws" {
  region = "us-west-2"
}

resource "random_password" "password" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "corerpc" {
  name = "corerpc"
}

resource "aws_secretsmanager_secret_version" "corerpc" {
  secret_id     = aws_secretsmanager_secret.corerpc.id
  secret_string = "http://bitcoin:${random_password.password.result}@${aws_instance.daemon.private_ip}:8332"
}

resource "aws_secretsmanager_secret" "corerpcpassword" {
  name = "corerpcpassword"
}

resource "aws_secretsmanager_secret_version" "corerpcpassword" {
  secret_id     = aws_secretsmanager_secret.corerpcpassword.id
  secret_string = random_password.password.result
}

resource "aws_secretsmanager_secret" "sfuser" {
  name = "sfuser"
}

resource "aws_secretsmanager_secret_version" "sfuser" {
  secret_id     = aws_secretsmanager_secret.sfuser.id
  secret_string = snowflake_user.user.name
}

resource "aws_secretsmanager_secret" "sfaccount" {
  name = "sfaccount"
}

resource "aws_secretsmanager_secret_version" "sfaccount" {
  secret_id     = aws_secretsmanager_secret.sfaccount.id
  secret_string = var.snowflake_account
}

resource "aws_secretsmanager_secret" "sfprivatekey" {
  name = "sfprivatekey"
}

resource "aws_secretsmanager_secret_version" "sfprivatekey" {
  secret_id     = aws_secretsmanager_secret.sfprivatekey.id
  secret_string = tls_private_key.svc_key.private_key_pem
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name = "name"

    values = [
      "amzn2-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

resource "aws_security_group_rule" "full-node" {
  type              = "ingress"
  from_port         = 8333
  to_port           = 8333
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.security_group.this_security_group_id
}

resource "aws_security_group_rule" "custom-rpc" {
  type              = "ingress"
  from_port         = 8332
  to_port           = 8332
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.default.cidr_block]
  security_group_id = module.security_group.this_security_group_id
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "btc2snow"
  description = "Security group btc2snowflake project"
  vpc_id      = data.aws_vpc.default.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["all-icmp", "ssh-tcp"]
  egress_rules        = ["all-all"]
}

resource "aws_network_interface" "this" {
  count = 1

  subnet_id = tolist(data.aws_subnet_ids.all.ids)[count.index]
}

resource "aws_iam_role" "daemon_role" {
  name = "daemon_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "daemon_profile" {
  name = "daemon_profile"
  role = aws_iam_role.daemon_role.name
}

resource "aws_iam_role_policy" "daemon_policy" {
  name = "daemon_policy"
  role = aws_iam_role.daemon_role.id

  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement": [
    {
      "Action": [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:GetAuthorizationToken",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds",
          "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_instance" "daemon" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = tolist(data.aws_subnet_ids.all.ids)[0]
  vpc_security_group_ids      = [module.security_group.this_security_group_id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.daemon_profile.name

  user_data = templatefile("user-data.sh.tpl", {
    password     = random_password.password.result,
    start_bucket = aws_s3_bucket_object.startup_script.bucket
  })

  tags = {
    Name = "bitcoind"
  }

  root_block_device {
    volume_type = "standard"
    volume_size = 32
  }

  ebs_block_device {
    device_name = "/dev/sdg"
    delete_on_termination = true
    snapshot_id = var.snapshot != "none" ? var.snapshot : null
    volume_size = 512
    volume_type = var.volume_type
  }
}

resource "aws_eip" "ip" {
  vpc      = true
  instance = aws_instance.daemon.id
}

resource "aws_s3_bucket" "data" {
  bucket = "btc2snowflake-rpc2stage"
  acl    = "private"
}

resource "aws_s3_bucket_object" "startup_script" {
  key    = "start.sh"
  bucket = aws_s3_bucket.data.id
  source = "start.sh"
  etag   = filemd5("start.sh")
}