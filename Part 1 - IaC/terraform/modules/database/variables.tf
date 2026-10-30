variable "project_name" {
  description = "Project name used in resource names."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs that can host RDS."
  type        = list(string)
}

variable "db_security_group_id" {
  description = "Security group ID for the RDS instance."
  type        = string
}

variable "database_name" {
  description = "Name of the MySQL database schema."
  type        = string
  default     = "lmsdb"
}

variable "username" {
  description = "Master username for the MySQL instance."
  type        = string
  default     = "lmsadmin"
}

variable "password" {
  description = "Master password for the MySQL instance."
  type        = string
  sensitive   = true
  default     = "ReplaceMeWithSecurePassword123!"
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "Initial RDS storage allocation in GiB."
  type        = number
  default     = 20
}

variable "enable_storage_autoscaling" {
  description = "Whether to enable RDS storage autoscaling."
  type        = bool
  default     = true
}

variable "max_allocated_storage" {
  description = "Maximum storage in GiB for RDS storage autoscaling."
  type        = number
  default     = 100
}

variable "enable_performance_alarms" {
  description = "Whether to create CloudWatch alarms for RDS health and scaling signals."
  type        = bool
  default     = true
}

variable "cpu_high_alarm_threshold" {
  description = "High CPU threshold for the RDS instance alarm."
  type        = number
  default     = 80
}

variable "database_connections_high_threshold" {
  description = "High database connections threshold for RDS alarm."
  type        = number
  default     = 500
}

variable "free_storage_space_low_threshold_bytes" {
  description = "Low free storage space threshold in bytes for RDS alarm."
  type        = number
  default     = 10737418240
}

variable "freeable_memory_low_threshold_bytes" {
  description = "Low freeable memory threshold in bytes for RDS alarm."
  type        = number
  default     = 268435456
}

variable "alarm_period_seconds" {
  description = "CloudWatch alarm period in seconds."
  type        = number
  default     = 60
}

variable "alarm_evaluation_periods" {
  description = "CloudWatch alarm evaluation periods."
  type        = number
  default     = 2
}
