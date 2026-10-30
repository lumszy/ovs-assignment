variable "project_name" {
  description = "Project name used in naming and tags."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID for this environment."
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR for the VPC."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks, one per AZ."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks, one per AZ."
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones used in the 3-AZ subnet layout."
  type        = list(string)
}

variable "db_instance_class" {
  description = "DB instance class."
  type        = string
}

variable "db_allocated_storage" {
  description = "DB allocated storage in GiB."
  type        = number
}

variable "db_password" {
  description = "The database password."
  type        = string
  sensitive   = true
}

variable "app_ami_id" {
  description = "AMI ID for the EC2 application instances. Placeholder value acceptable for offline validation."
  type        = string
}

variable "app_instance_type" {
  description = "EC2 instance type for the app tier."
  type        = string
}

variable "app_min_size" {
  description = "Minimum ASG size."
  type        = number
}

variable "app_desired_capacity" {
  description = "Desired ASG size."
  type        = number
}

variable "app_max_size" {
  description = "Maximum ASG size."
  type        = number
}
