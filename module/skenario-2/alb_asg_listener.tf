resource "aws_lb" "alb_production" {
  name            = "${var.project_name}-alb"
  internal        = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.sg_instance.id]
  subnets         = flatten([var.vpc_public_subnets_id])
  idle_timeout = 720
}

### AUTO SCALLING GRUP
resource "aws_autoscaling_group" "ecs_asg_terraform" {
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
        launch_template_id = aws_launch_template.launch_template.id
        version = "$Latest"
      }

      override {
        instance_type     = var.instance_type
      }
    }
  }
}

resource "aws_lb_target_group" "alb_target" {
  name        = "${var.project_name}-target"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id                              //target instance
  health_check {
    path                = "/health"
    healthy_threshold   = 3
    interval            = 20
    unhealthy_threshold = 2
  }
  deregistration_delay = "200"
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb_production.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target.arn
  }
}