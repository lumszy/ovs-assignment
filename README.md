# OVS DevOps AWS Assignment Repo

This repository contains the infrastructure and delivery work for the Maple Online Academy take-home assignment.

## Layout

- `Assignment.pdf` — original requirement brief
- `Part 1 - IaC` — Terraform for the target AWS platform for both Dev and Prod Environment.
- `Part 2 — CICD` — GitHub Actions workflow yaml file, trust policy, and release/rollback note
- `Part 3 — Design_doc` — migration, DR, observability, edge, and security design document

## Assumptions
My assumptions are as follows:
- Dev and prod are separate AWS accounts with the account IDs `111111111111` and `222222222222` respectively.
- Deployment is for Canada Central (`ca-central-1`).
- The LMS is the primary workload being moved to AWS; the WordPress/WooCommerce store, cron jobs, and Cloudflare setup are intentionally left out of the Terraform scope.
- The app is a traditional PHP 8.2 monolith running on Apache, so the chosen architecture is EC2 + Auto Scaling + Application Load Balancer instead of a container-first design.
- The requirement to create 3 AZs means each AZ has a public subnet and a private subnet, for a total of 6 subnets across the VPC.
- This work is intentionally validated with `terraform fmt` and `terraform validate`; no AWS apply is performed.
- I commented out the terraform backend block definition to test locally.  `terraform plan` runs as seen below.

```
      + tags_all                             = {
          + "AccountId"   = "111111111111"
          + "AccountType" = "dev"
          + "Environment" = "dev"
          + "ManagedBy"   = "terraform"
          + "Name"        = "maple-ova-dev-vpc"
          + "Project"     = "maple-ova"
        }
    }

Plan: 45 to add, 0 to change, 0 to destroy.

```


## What is left out

- WordPress/WooCommerce infrastructure
- Cron job infrastructure or job runner setup
- Cloudflare configuration
- Real production certificate or complete WAF tuning
- Full zero-downtime database migration strategy beyond the target-state architecture

## AI usage note

This project was developed with the assistance of AI tooling for code generation, review, and Terraform validation support. The design decisions were reviewed and adjusted to match the assignment requirements, with explicit assumptions documented here.

## Current status

- Part 1 — Infrastructure as Code is complete and validated with placeholder values in variables.
- Part 2 — CI/CD has been added with a realistic GitHub Actions deployment flow from merge to dev and then prod via manual promotion.
- Part 3 design doc has been added in Markdown file named `design-doc.md` in `Part 3 - Design_doc` folder
