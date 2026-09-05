# Terraform Lambda Deployment via GitHub Actions

This repository deploys an AWS Lambda function from an S3 artifact using Terraform, including optional Lambda Layer deployment.

## Prerequisites
- AWS account with IAM permissions for Terraform-managed resources.
- Terraform CLI (for local runs).
- S3 bucket containing versioned Lambda artifacts (`.zip`).
- GitHub repository with Actions enabled.

## Repository Layout (expected)
- `terraform/` root IaC configuration
- `terraform/modules/iam` IAM role and policies
- `terraform/modules/s3_artifact` artifact lookup/management
- `terraform/modules/lambda_layer` Lambda layer from S3 artifact
- `terraform/modules/lambda_function` Lambda function from S3 artifact
- `.github/workflows/terraform-deploy.yml` deployment workflow

## Required GitHub Configuration

### Option A (Recommended): OIDC Federation
Configure AWS trust for GitHub OIDC and create a deploy role.

Set repository variables/secrets:
- `AWS_ROLE_ARN` (Repository variable or secret)
- `AWS_REGION` (Repository variable)

No long-lived AWS keys are required.

### Option B: Access Keys (Fallback)
Set repository secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`

## Terraform Backend
Use one of the following:
1. Local backend for bootstrap.
2. Remote backend (recommended) with:
   - S3 bucket for `terraform.tfstate`
   - DynamoDB table for state locking

If backend config is externalized, pass it during init:
```bash
terraform init -backend-config=backend.hcl
```

## Environment Variables and tfvars
Create environment-specific files such as:
- `terraform/environments/dev.tfvars`
- `terraform/environments/stage.tfvars`
- `terraform/environments/prod.tfvars`

Typical values:
- `environment`
- `lambda_function_name`
- `lambda_runtime`
- `lambda_handler`
- `artifact_bucket`
- `artifact_key`
- `artifact_version`
- `layer_artifact_key` (optional)
- `layer_artifact_version` (optional)

## GitHub Actions Workflow
A typical workflow should:
1. Checkout repository.
2. Setup Terraform.
3. Configure AWS credentials (OIDC/access keys).
4. Run `terraform init`.
5. Run `terraform fmt -check`.
6. Run `terraform validate`.
7. Run `terraform plan -var-file=environments/<env>.tfvars`.
8. Run `terraform apply -var-file=environments/<env>.tfvars` (main branch or manual approval).

## Example workflow skeleton
```yaml
name: Terraform Deploy

on:
  pull_request:
    paths:
      - 'terraform/**'
      - '.github/workflows/terraform-deploy.yml'
  push:
    branches: [ main ]
    paths:
      - 'terraform/**'
      - '.github/workflows/terraform-deploy.yml'
  workflow_dispatch:
    inputs:
      environment:
        description: 'Target environment'
        required: true
        default: 'dev'

jobs:
  terraform:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    defaults:
      run:
        working-directory: terraform
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Configure AWS credentials (OIDC)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ vars.AWS_ROLE_ARN }}
          aws-region: ${{ vars.AWS_REGION }}

      - name: Terraform Init
        run: terraform init

      - name: Terraform Format Check
        run: terraform fmt -check

      - name: Terraform Validate
        run: terraform validate

      - name: Terraform Plan
        run: terraform plan -var-file=environments/dev.tfvars

      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve -var-file=environments/dev.tfvars
```

## Deployment Steps
1. Upload Lambda and optional layer zip artifacts to S3 (with versioning enabled).
2. Update tfvars with the artifact key and version.
3. Trigger workflow via push or `workflow_dispatch`.
4. Review plan output.
5. Approve/apply (based on branch/environment protections).

## Recommended Controls
- Use S3 object version IDs for immutable deployments.
- Use GitHub Environments (`dev`, `stage`, `prod`) with required reviewers.
- Restrict OIDC role trust policy by repository and branch.
- Separate state and variables by environment.

## Troubleshooting
- `AccessDenied`: verify IAM policies and OIDC trust conditions.
- `NoSuchKey`: confirm artifact key and object version in S3.
- Backend lock issues: verify DynamoDB lock table and permissions.
- Drift/mismatch: run `terraform plan` and avoid manual console changes.
