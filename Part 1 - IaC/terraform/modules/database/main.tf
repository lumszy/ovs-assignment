resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnets"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-${var.environment}-db-subnets"
  }
}

resource "aws_db_instance" "main" {
  identifier                      = "${var.project_name}-${var.environment}-mysql"
  allocated_storage               = var.allocated_storage
  max_allocated_storage           = var.enable_storage_autoscaling ? var.max_allocated_storage : null
  storage_type                    = "gp3"
  engine                          = "mysql"
  engine_version                  = "8.0"
  instance_class                  = var.instance_class
  db_name                         = var.database_name
  username                        = var.username
  password                        = var.password
  parameter_group_name            = "default.mysql8.0"
  db_subnet_group_name            = aws_db_subnet_group.main.name
  vpc_security_group_ids          = [var.db_security_group_id]
  publicly_accessible             = false
  skip_final_snapshot             = true
  backup_retention_period         = 7
  multi_az                        = true
  storage_encrypted               = true
  deletion_protection             = false
  performance_insights_enabled    = true
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]

  tags = {
    Name = "${var.project_name}-${var.environment}-mysql"
  }
}

resource "aws_cloudwatch_metric_alarm" "db_cpu_high" {
  count = var.enable_performance_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-db-cpu-high"
  alarm_description   = "RDS CPU utilization is above the high threshold."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = var.alarm_period_seconds
  statistic           = "Average"
  threshold           = var.cpu_high_alarm_threshold

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }
}

resource "aws_cloudwatch_metric_alarm" "db_connections_high" {
  count = var.enable_performance_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-db-connections-high"
  alarm_description   = "RDS database connections are above the high threshold."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = var.alarm_period_seconds
  statistic           = "Average"
  threshold           = var.database_connections_high_threshold

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }
}

resource "aws_cloudwatch_metric_alarm" "db_free_storage_low" {
  count = var.enable_performance_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-db-free-storage-low"
  alarm_description   = "RDS free storage space is below the low threshold."
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = var.alarm_period_seconds
  statistic           = "Average"
  threshold           = var.free_storage_space_low_threshold_bytes

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }
}

resource "aws_cloudwatch_metric_alarm" "db_freeable_memory_low" {
  count = var.enable_performance_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-db-freeable-memory-low"
  alarm_description   = "RDS freeable memory is below the low threshold."
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = var.alarm_period_seconds
  statistic           = "Average"
  threshold           = var.freeable_memory_low_threshold_bytes

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }
}
