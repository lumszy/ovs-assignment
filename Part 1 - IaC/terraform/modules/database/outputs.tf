output "db_instance_id" {
  description = "RDS instance identifier."
  value       = aws_db_instance.main.id
}

output "db_username" {
  description = "Master username for the RDS instance."
  value       = aws_db_instance.main.username
}

output "database_name" {
  description = "Database name created on the RDS instance."
  value       = aws_db_instance.main.db_name
}

output "db_endpoint" {
  description = "RDS endpoint hostname."
  value       = aws_db_instance.main.address
}

output "db_port" {
  description = "RDS port."
  value       = aws_db_instance.main.port
}

