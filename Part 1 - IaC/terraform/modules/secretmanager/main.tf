resource "aws_secretsmanager_secret" "app" {
  name = "${var.project_name}/${var.environment}/app"

  tags = {
    Name = "${var.project_name}-${var.environment}-app-secret"
  }
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id = aws_secretsmanager_secret.app.id
  secret_string = jsonencode({
    s3_bucket = var.app_bucket_name
    region    = var.aws_region
  })
}

resource "aws_secretsmanager_secret" "database" {
  name = "${var.project_name}/${var.environment}/database"

  tags = {
    Name = "${var.project_name}-${var.environment}-database-secret"
  }
}

resource "aws_secretsmanager_secret_version" "database" {
  secret_id = aws_secretsmanager_secret.database.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    host     = var.db_host
    port     = var.db_port
    dbname   = var.db_name
  })
}
