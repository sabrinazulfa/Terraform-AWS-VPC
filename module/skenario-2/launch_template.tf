### Launch Template Resource
resource "aws_iam_instance_profile" "custom-profile" {
  name = "${var.project_name}-customInstanceProfile"
  role = aws_iam_role.alb_role.name
}

resource "aws_launch_template" "launch_template" {
  name          = "${var.project_name}-launch-template"
  instance_type = var.instance_type
  image_id      = var.aws_ami
  iam_instance_profile {
    name = aws_iam_instance_profile.custom-profile.name
  }
  key_name = var.key_pair
  network_interfaces {
    security_groups = [aws_security_group.sg_instance.id]
  }
  user_data     = base64encode(data.template_file.startup_script.rendered)
  ebs_optimized = false
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.volume_size
      delete_on_termination = true
      volume_type           = var.volume_type # "gp3" # default is gp2
      encrypted             = "false"
    }
  }
  monitoring {
    enabled = false
  }
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.project_name}-instance"
    }
  }
  lifecycle {
    ignore_changes = [description]
  }
}

data "template_file" "startup_script" {
  template = file("${path.module}/user-data.sh")
}