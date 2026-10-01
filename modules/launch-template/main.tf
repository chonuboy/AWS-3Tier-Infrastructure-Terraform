data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_launch_template" "this" {
  name_prefix   = var.lt-name
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
    user_data = base64encode(
    file("${path.module}/../../scripts/app-user-data.sh")
  )
  vpc_security_group_ids = [var.security-group-id]

  iam_instance_profile {
    name = var.instance_profile_name
  }

  lifecycle {
    create_before_destroy = true
  }
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "three-tier-app"
    }
  }
}
