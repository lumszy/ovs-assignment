variable "project_name" {
  description = "Project name used in resource names."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID."
  type        = string
}

variable "public_subnet_ids" {
  description = "Subnet IDs for the ALB in public subnets."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Subnet IDs for application instances in private subnets."
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID for the ALB."
  type        = string
}

variable "app_security_group_id" {
  description = "Security group ID for the app nodes."
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 application instances. A placeholder value is acceptable for plan validation."
  type        = string
  default     = "ami-0123456789abcdef0"
}

variable "instance_type" {
  description = "EC2 instance type for the application tier."
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "Minimum ASG capacity."
  type        = number
  default     = 2
}

variable "desired_capacity" {
  description = "Desired ASG capacity."
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum ASG capacity."
  type        = number
  default     = 4
}

variable "enable_scaling_policies" {
  description = "Whether to create ASG target-tracking autoscaling policies."
  type        = bool
  default     = true
}

variable "enable_scaling_alarms" {
  description = "Whether to create CloudWatch alarms for app-tier scaling signals."
  type        = bool
  default     = true
}

variable "target_cpu_utilization" {
  description = "Target average CPU utilization percentage for ASG target tracking."
  type        = number
  default     = 60
}

variable "target_request_count_per_target" {
  description = "Target ALB requests per target for ASG target tracking."
  type        = number
  default     = 800
}

variable "estimated_instance_warmup_seconds" {
  description = "Estimated warm-up time in seconds for new EC2 instances."
  type        = number
  default     = 180
}

variable "cpu_high_alarm_threshold" {
  description = "High CPU threshold for app tier alarm."
  type        = number
  default     = 80
}

variable "cpu_low_alarm_threshold" {
  description = "Low CPU threshold for app tier alarm."
  type        = number
  default     = 20
}

variable "request_count_high_alarm_threshold" {
  description = "High ALB requests-per-target threshold for app tier alarm."
  type        = number
  default     = 1200
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

variable "upload_bucket_arn" {
  description = "ARN for the upload bucket used by the app."
  type        = string
}

variable "app_secret_arn" {
  description = "Secrets Manager ARN that stores the app configuration."
  type        = string
}
