### Launch Template Resource
resource "aws_iam_instance_profile" "attacker-profile" {
  name = "${var.project_name}-attackerInstanceProfile"
  role = aws_iam_role.attacker_role.name
}

resource "aws_launch_template" "attacker_launch_template" {
  name          = "${var.project_name}-launch-template"
  instance_type = var.instance_type
  image_id      = var.aws_ami
  iam_instance_profile {
    name = aws_iam_instance_profile.attacker-profile.name
  }
  key_name = var.key_pair
  network_interfaces {
    security_groups = [aws_security_group.attacker_instance.id]
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
      Name = "${var.project_name}"
    }
  }
  lifecycle {
    ignore_changes = [tags, description]
  }
}

data "template_file" "startup_script" {
  template = file("${path.module}/user-data.sh")
}

resource "aws_autoscaling_group" "attackerasg_terraform" {
  name                = "${var.project_name}-auto-scalling-group"
  capacity_rebalance  = var.capacity_rebalance
  desired_capacity    = var.desired_capacity
  max_size            = var.max_capacity
  min_size            = var.min_capacity
  vpc_zone_identifier = flatten([var.vpc_private_subnets_id])
  protect_from_scale_in = false

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = var.on_demand_percentage
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.attacker_launch_template.id
        version = "$Latest"
      }

      override {
        instance_type     = var.instance_type
      }
    }
  }
}