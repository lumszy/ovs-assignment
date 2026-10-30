output "app_secret_arn" {
  description = "ARN of the application secret."
  value       = aws_secretsmanager_secret.app.arn
}

output "database_secret_arn" {
  description = "ARN of the database secret."
  value       = aws_secretsmanager_secret.database.arn
}
