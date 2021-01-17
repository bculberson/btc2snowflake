provider "aws" {
  region = "us-west-2"
}

resource "random_password" "password" {
  length  = 16
  special = false
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
      "amzn2-ami-hvm-*-arm64-gp2",
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
  role = "${aws_iam_role.daemon_role.name}"
}

resource "aws_iam_role_policy" "daemon_policy" {
  name = "daemon_policy"
  role = "${aws_iam_role.daemon_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:GetAuthorizationToken"
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
  instance_type               = "t4g.large"
  subnet_id                   = tolist(data.aws_subnet_ids.all.ids)[0]
  vpc_security_group_ids      = [module.security_group.this_security_group_id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.daemon_profile.name

  user_data = templatefile("user-data.sh.tpl", {
    password = random_password.password.result
  })

  tags = {
    Name = "bitcoind"
  }

  root_block_device {
    volume_type = "standard"
    volume_size = 10
  }

  ebs_block_device {
    device_name           = "/dev/sdg"
    volume_size           = 512
    volume_type           = "sc1"
    delete_on_termination = true
  }
}

resource "aws_eip" "ip" {
  vpc      = true
  instance = aws_instance.daemon.id
}

output "ip" {
  value = aws_eip.ip.public_ip
}

output "rpcpassword" {
  value = random_password.password.result
}