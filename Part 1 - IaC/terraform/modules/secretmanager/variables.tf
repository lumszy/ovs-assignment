variable "project_name" {
  description = "Short project name used in secret names."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "aws_region" {
  description = "AWS region for the app configuration secret."
  type        = string
}

variable "app_bucket_name" {
  description = "Name of the student upload bucket."
  type        = string
}

variable "db_username" {
  description = "Database username to store in the secret."
  type        = string
}

variable "db_password" {
  description = "Database password to store in the secret."
  type        = string
  sensitive   = true
}

variable "db_host" {
  description = "Database hostname to store in the secret."
  type        = string
}

variable "db_port" {
  description = "Database port to store in the secret."
  type        = number
}

variable "db_name" {
  description = "Database name to store in the secret."
  type        = string
}
