# Part 1 — Infrastructure as Code

This directory contains the target-state Terraform architecture for the LMS platform in `ca-central-1`.

## Architecture summary

- 3-AZ VPC with 3 public subnets and 3 private subnets
- Internet-facing Application Load Balancer in public subnets
- PHP web tier running in EC2 Auto Scaling Groups inside private subnets
- Production app autoscaling policies based on CPU and ALB request-per-target metrics, with CloudWatch alarms
- Managed MySQL 8 database in a private subnet group with multi-AZ enabled
- Production RDS storage autoscaling with CloudWatch alarms for CPU, connections, free storage, and memory
- Student upload storage in an encrypted S3 bucket
- IAM instance profile and Secrets Manager wiring for app access
- Dev and prod separated by AWS account ID

## Account assumptions

- Dev account: `111111111111`
- Prod account: `222222222222`
- Region: `ca-central-1`

## Terraform layout

- `terraform/environments/dev` — dev environment definition and backend config
- `terraform/environments/prod` — prod environment definition and backend config
- `terraform/modules/vpc` — VPC, subnets, routing, NAT, and Internet Gateway
- `terraform/modules/security_groups` — security groups for ALB, apps, and DB
- `terraform/modules/app` — ALB, target groups, launch template, and ASG
- `terraform/modules/database` — RDS MySQL instance configuration
- `terraform/modules/storage` — upload bucket and encryption settings
- `terraform/modules/secretmanager` — application and database secrets for AWS Secrets Manager

## Included in scope

- Networking across 3 AZs
- Load-balanced web tier for the PHP application
- Managed MySQL 8 database
- Student upload storage
- IAM and secrets structure to support app access
- Remote state configuration stubs for S3-backed Terraform state

## Left out intentionally

- WordPress store
- Cron jobs and job orchestration
- Cloudflare configuration and edge logic
- Real certificate management and WAF tuning
- Full database migration runbooks or restore drills

## Validation

The Terraform code is structured to support:

- `terraform fmt`
- `terraform validate`
- a successful plan against placeholder values

No actual AWS apply is performed in this repo.

## Assumptions to keep in mind

- This code is a realistic production baseline, not a full business continuity or enterprise rollout.
- The DB master password and app secrets are placeholder values for validation and should be replaced by secure secret management before real deployment.
- The architecture is designed for a PHP monolith, not a serverless-first model.
- The app Auto Scaling Group is configured to keep at least one instance per private subnet (3 AZs) to preserve multi-AZ app placement.
