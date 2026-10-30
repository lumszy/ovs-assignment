# Part 2 — CI/CD

This folder contains the GitHub Actions pipeline and the AWS OIDC trust-policy pattern for delivering the LMS application from merge to production, with the dev environment acting as the validation hop before prod.

## Assumptions

- The repository name is `lumszy/ovs-assignment`.
- GitHub Actions uses AWS OIDC so no long-lived AWS access keys are stored in GitHub secrets.
- Dev and prod run in separate AWS accounts: `111111111111` and `222222222222` respectively.
- The app is a PHP monolith with a `composer.json` and PHPUnit suite.
- Deployments happen through a release artifact stored in S3, then executed on the EC2 app nodes using SSM commands.
- Production release is gated by a GitHub environment approval before the prod workflow runs.

## Workflow behavior

The workflow in `.github/workflows/deploy.yml` does the following:

1. On push to `main`, it runs composer install and PHPUnit tests.
2. If tests pass, it creates a release tarball and stores it as a GitHub Actions artifact.
3. It deploys that artifact to the dev environment automatically.
4. It runs a lightweight health check against the ALB.
5. A production promotion happens only through `workflow_dispatch` and requires the GitHub `production` environment approval.

This matches the requirement to move a change from merge to running in production by way of dev.

## AWS OIDC trust policy

The trust policy is documented in `aws-oidc-trust-policy.json`. Its intent is to allow only the GitHub repository and the correct GitHub environment to assume the AWS deployment role.

The policy pattern is:

- allow only `token.actions.githubusercontent.com` as the federated identity provider
- require the audience to be `sts.amazonaws.com`
- restrict the subject to the specific repo and environment, for example:
  - `repo:lumszy/ovs-assignment:environment:dev`
  - `repo:lumszy/ovs-assignment:environment:production`

This avoids storing static AWS credentials in the repository and keeps the deployment path auditable.

## Release and rollback flow

Releases are tracked by commit SHA and stored in S3 under `releases/<sha>.tar.gz` in each account. The deployment step copies the approved artifact to the account-specific artifact bucket, then swaps the application directory on the EC2 instances through a symlink change.

Rollback is intentionally simple and fast:

- keep the last N release archives in the bucket
- re-run the workflow against the previously known-good SHA, or re-trigger the environment deploy using the earlier artifact
- use a symlink swap or directory rollback on the app nodes to restore the last healthy release

This keeps recovery fast without rebuilding the whole stack.

## Files included

- `.github/workflows/deploy.yml` — GitHub Actions CI/CD pipeline
- `aws-oidc-trust-policy.json` — OIDC trust-policy template for dev and prod roles

## Notes

The example ALB hostnames and bucket names are placeholders. In a real setup, they would be replaced with the actual Terraform outputs, such as the dev/prod ALB DNS name or the S3 artifact bucket names created in Part 1.
