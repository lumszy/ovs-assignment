resource "aws_iam_role" "app" {
  name = "${var.project_name}-${var.environment}-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "app" {
  name = "${var.project_name}-${var.environment}-app-policy"
  role = aws_iam_role.app.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowReadWriteUploadBucket"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${var.upload_bucket_arn}",
          "${var.upload_bucket_arn}/*"
        ]
      },
      {
        Sid    = "AllowSecretsRead"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [var.app_secret_arn]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "app" {
  name = "${var.project_name}-${var.environment}-app-profile"
  role = aws_iam_role.app.name
}

resource "aws_lb" "app" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "${var.project_name}-${var.environment}-alb"
  }
}

resource "aws_lb_target_group" "app" {
  name     = "${var.project_name}-${var.environment}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    matcher             = "200-399"
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
  }

  target_type = "instance"
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-${var.environment}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = [var.app_security_group_id]

  iam_instance_profile {
    arn = aws_iam_instance_profile.app.arn
  }

  user_data = base64encode(<<-EOT
    #!/bin/bash
    yum update -y
    yum install -y httpd php8.2 php8.2-mysqlnd
    systemctl enable httpd
    systemctl start httpd
    echo "Application is running on ${var.environment}" > /var/www/html/index.html
    mkdir -p /var/www/html/health
    echo "ok" > /var/www/html/health/index.html
  EOT
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-${var.environment}-app-node"
    }
  }
}

locals {
  app_az_count               = length(var.private_subnet_ids)
  effective_min_size         = max(var.min_size, local.app_az_count)
  effective_desired_capacity = max(var.desired_capacity, local.effective_min_size)
  effective_max_size         = max(var.max_size, local.effective_desired_capacity)
}

resource "aws_autoscaling_group" "app" {
  name_prefix               = "${var.project_name}-${var.environment}-asg-"
  vpc_zone_identifier       = var.private_subnet_ids
  min_size                  = local.effective_min_size
  desired_capacity          = local.effective_desired_capacity
  max_size                  = local.effective_max_size
  health_check_type         = "ELB"
  health_check_grace_period = 300
  target_group_arns         = [aws_lb_target_group.app.arn]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-app"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "cpu_target_tracking" {
  count = var.enable_scaling_policies ? 1 : 0

  name                      = "${var.project_name}-${var.environment}-cpu-target-tracking"
  policy_type               = "TargetTrackingScaling"
  autoscaling_group_name    = aws_autoscaling_group.app.name
  estimated_instance_warmup = var.estimated_instance_warmup_seconds

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = var.target_cpu_utilization
  }
}

resource "aws_autoscaling_policy" "alb_request_target_tracking" {
  count = var.enable_scaling_policies ? 1 : 0

  name                      = "${var.project_name}-${var.environment}-requests-target-tracking"
  policy_type               = "TargetTrackingScaling"
  autoscaling_group_name    = aws_autoscaling_group.app.name
  estimated_instance_warmup = var.estimated_instance_warmup_seconds

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${aws_lb.app.arn_suffix}/${aws_lb_target_group.app.arn_suffix}"
    }

    target_value = var.target_request_count_per_target
  }
}

resource "aws_cloudwatch_metric_alarm" "app_cpu_high" {
  count = var.enable_scaling_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-app-cpu-high"
  alarm_description   = "Average app tier CPU is above the high threshold."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.alarm_period_seconds
  statistic           = "Average"
  threshold           = var.cpu_high_alarm_threshold

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }
}

resource "aws_cloudwatch_metric_alarm" "app_cpu_low" {
  count = var.enable_scaling_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-app-cpu-low"
  alarm_description   = "Average app tier CPU is below the low threshold."
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.alarm_period_seconds
  statistic           = "Average"
  threshold           = var.cpu_low_alarm_threshold

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_request_count_high" {
  count = var.enable_scaling_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-alb-requests-high"
  alarm_description   = "Average requests per target are above the high threshold."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "RequestCountPerTarget"
  namespace           = "AWS/ApplicationELB"
  period              = var.alarm_period_seconds
  statistic           = "Average"
  threshold           = var.request_count_high_alarm_threshold

  dimensions = {
    LoadBalancer = aws_lb.app.arn_suffix
    TargetGroup  = aws_lb_target_group.app.arn_suffix
  }
}
