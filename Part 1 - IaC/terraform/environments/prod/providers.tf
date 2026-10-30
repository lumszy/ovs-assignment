terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Remote state configuration for real AWS deployments.
  # backend "s3" {
  #   bucket         = "maple-ova-tfstate-prod"
  #   key            = "prod/terraform.tfstate"
  #   region         = "ca-central-1"
  #   encrypt        = true
  #   dynamodb_table = "maple-ova-tfstate-lock-prod"
  # }

  backend "local" {}
}

provider "aws" {
  region                      = var.aws_region
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
      AccountType = var.environment
      AccountId   = var.aws_account_id
    }
  }
}
