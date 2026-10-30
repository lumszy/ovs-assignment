# Part 3 — Design Document

## Context and objective

Maple Online Academy currently runs on a single VPS and serves roughly 15,000 active students. The business goal is to migrate this infrastructure to AWS in `ca-central-1` with minimal to no visible downtime during exam periods, while also improving resilience, operability, and security.

The target operating model is:

- LMS app tier on EC2 Auto Scaling behind an Application Load Balancer
- MySQL 8 on Amazon RDS with Multi-AZ
- Student uploads in Amazon S3
- Separate dev and prod AWS accounts
- Delivery through GitHub Actions + OIDC

This design focuses on practical execution risk reduction: move safely first, then optimize.

---

## 3.1) Migration plan (including store, cron jobs, and uploads)

### A. Migration strategy
  -  **Parallel-run before cutover**: build and validate the AWS stack while the VPS remains source-of-truth.
  - **Rehearse repeatedly**: i will test in non-prod(dev) first before production migration.
    - dev validation
  - **Minimize write-freeze window**: use replication and incremental sync wherever possible to move files changes.
  - **Rollback must be preplanned**: DNS rollback, data rollback boundaries, and explicit abort criteria.



#### B. Student uploads

- Perform initial bulk transfer from VPS filesystem to S3.
- Run incremental sync jobs until cutover (`rsync`/`aws s3 sync` pattern).
- During cutover, execute a final delta sync after write freeze.
- Preserve object paths and references expected by the LMS.
- Enable S3 versioning to reduce accidental overwrite/deletion risk.

#### C. WordPress/WooCommerce store
- Mirror approach used for LMS:
  - app migration to dedicated ASG (or isolated service stack)
  - database to RDS (same migration pattern)
  - media uploads to S3 (+ optional CloudFront origin pull)
- Keep store deployment logically isolated from LMS blast radius (separate ASG, SGs, and preferably separate DB instance).


Cron:
- Use **AWS Cloudwatch EventBridge scheduler** as primary scheduler.
- Execute jobs on:
  - Lambda scripts (fx)
  - SSM/EC2 runner for legacy scripts during transition.

---

## 3.2) Backups and disaster recovery (with RTO/RPO)

### 3.2.1 Targets to commit
For LMS production:

- **RTO**: 60 minutes for regional service restoration
- **RPO**: 15 minutes for relational data, near-zero for uploads with versioning and replication

For WordPress/WooCommerce:

- **RTO**: 60 minutes
- **RPO**: 15–30 minutes depending on replication mode

### 3.2.2 Backup design
#### Database
- Depends on Company policy, RDS automated backups enabled with retention (e.g., 14–30 days). 
- Point-in-time recovery enabled.
- Daily snapshot copy policy to secondary region for DR.
- Periodic restore tests in non-prod to validate backup usability.

#### Uploads and media
- Configure S3 versioning + lifecycle management on buckets.
- Cross-Region Replication for critical buckets.
- Configure S3 Event Put notifications with SNS. Captures when students uplods assignments.

#### Configuration and infrastructure
- Terraform code in Git (versioned infra definition).
- Secrets Manager rotation where supported; versioned secret history.
- CI workflow definitions and run logs retained.

### 2.3 DR execution model
- **Single-region failure mode**:
  - restore DB from latest snapshot in secondary region
  - promote replicated S3 bucket/object access
  - deploy app stack from Terraform + CI artifact
  - repoint Cloudflare origin to DR endpoint

- Quarterly DR game day:
  - timed drill against RTO/RPO
  - documented runbook improvements after each drill

---

## 3) Observability and alerting
### 3.1 The following will be capture at each layers;

1. **Infrastructure metrics** (CloudWatch):
   - ALB request rate, 4xx/5xx, target response time
   - ASG capacity and scaling activity
   - EC2 CPU/memory/disk (CloudWatch agent)
   - RDS CPU, connections, free storage, replication lag indicators

2. **Application logs**:
   - structured JSON logs with request IDs and user/session correlation IDs
   - centralized in CloudWatch Logs (or OpenSearch + Kibanna dashboards)
   
3. **define Users journey SLOs**:
   - login success rate
   - enrollment submission success
   - exam save/submit latency and error rate

### 3.2 Alerting model
- Route alerts by severity:
  - P1: paging (on-call)
  - P2: team channel + ticket
  - P3: backlog triage
- Composite alarms to reduce noise (for example high 5xx + high latency).
- Alert ownership mapped to service owners (LMS, DB, store, jobs).
- Include runbook links in every alert payload.

### 3.3 Operational readiness
- Define error budgets and SLO thresholds.
- Create dashboards for:
  - exam-period command center
  - deployment health
  - database performance
  - background jobs
- Track change events (deployments, schema changes) on charts for fast correlation.

---

## 4) Cloudflare edge design
### 4.1 Traffic and security controls

- Cloudflare remains DNS and edge entry point.
- Enable:
  - WAF managed rules
  - bot management/rate limiting
  - geo/IP reputation controls
  - DDoS protections
- Restrict origin access so only Cloudflare can reach ALB where practical (IP allowlists / authenticated origin pulls).

### 4.2 Caching strategy

- Cache static assets aggressively (images, CSS, JS, fonts).
- Bypass cache for authenticated LMS pages and checkout-like store paths.
- Cache HTML selectively only for safe anonymous pages.
- Use cache tags/purge hooks in deployment workflow to clear changed assets on release.

### 4.3 Edge reliability

- Health-check aware origin pools if blue/green or active/passive origins are used.
- Keep low DNS TTL during migration and high-change periods.
- Maintain edge rule configuration as code (Terraform/provider or API-managed templates) to reduce drift.

---

## 5) Access and secrets

### 5.1 Identity and access model
- Separate AWS accounts for dev and prod.
- Human access:
  - Through AWS IAM Identity Center (SSO)
  - least-privilege permission.
  - MFA mandatory
  - VPN Connectivity for login into accounts
  - MDM installed on official laptops
  
- Workload access:
  - IAM roles for EC2 instances
  - no static credentials on hosts
  - OIDC for github actions deployments

### 5.2 CI/CD access

- GitHub Actions uses OIDC federation to assume environment-scoped roles.
- Separate deploy roles per environment/account.
- Branch and environment protections enforce promotion control.

### 5.3 Secret management

- Store DB/app secrets in **AWS Secrets Manager**.
- Rotate database credentials on a defined schedule.
- Encrypt at rest with KMS-managed keys.
- Use short-lived credentials/tokens where supported.
- Detect secret leakage with secret scanning and alerting.


---

## My First 90 days plan 
1. **Production readiness gap assessment and runbooks**
   I will understand the environment and how the application works. Confirm dependency inventory, define cutover/rollback runbooks, finalize ownership, .

2. **Observability baseline + on-call alert routing** 
   Define Dashboards, logging and critical alarms

3. **Database and upload migration rehearsal in non-prod**  
   Dry-run full sync + cutover simulation, validate timing and data integrity.

4. **Cloudflare edge hardening and cache policy rollout**  
   WAF, rate limits, cache policies, and origin protections.

5. **Cron-job migration to managed scheduler**  
   Inventory jobs, move highest-risk jobs first, add idempotency and monitoring.

6. **Production canary migration and controlled cutover** 
   Canary route, acceptance criteria, rollback readiness, final migration.

7. **Post-cutover stabilization and DR drill** 
   Tune scaling thresholds, verify error budgets, perform first timed DR rehearsal.
