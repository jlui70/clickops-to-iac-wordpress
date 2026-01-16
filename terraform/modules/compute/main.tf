# Obter AMI mais recente do Amazon Linux 2
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Preparar user data
locals {
  user_data = templatefile("${path.module}/user-data.sh", {
    efs_dns_name = var.efs_dns_name
    db_host      = var.db_endpoint
    db_user      = var.db_username
    db_password  = var.db_password
    db_name      = var.db_name
  })
}

# Launch Template
resource "aws_launch_template" "wordpress" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"

  iam_instance_profile {
    name = var.instance_profile_name
  }

  vpc_security_group_ids = [var.app_security_group_id]

  user_data = base64encode(local.user_data)

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"
    http_put_response_hop_limit = 1
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project_name}-wordpress-instance"
      Environment = var.environment
    }
  }

  tags = {
    Name        = "wordpress-temp"
    Environment = var.environment
  }
}
