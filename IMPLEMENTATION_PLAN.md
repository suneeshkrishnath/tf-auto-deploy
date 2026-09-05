# Implementation Plan: Terraform Lambda Deployment from S3

## Section 1: Terraform Implementation Plan

This section describes what to build inside this repository using Terraform.

> **Current scope:** Implement **DEV** environment now. **STAGE/TEST** and **PROD** are deferred to a later phase.

### 1. Project Structure ✅ DONE
Create a clean Terraform layout so each concern is separated:

```text
terraform/
  versions.tf
  providers.tf
  backend.tf
  variables.tf
  main.tf
  outputs.tf
  environments/
    dev.tfvars
    stage.tfvars
    prod.tfvars
  modules/
    iam/
    s3_artifact/
    lambda_layer/
    lambda_function/
```

### 2. Version and Provider Setup ✅ DONE
- Pin Terraform version (for example `>= 1.6.0`).
- Pin AWS provider to a tested version range.
- Keep version pins in `versions.tf`.

### 3. Backend and State Management ✅ DONE
- Start with local backend during initial development.
- Move to remote backend (S3 + DynamoDB lock) before team usage.
- Store backend settings in `backend.tf` or external `backend.hcl`.

**Todo from SUNEESH in AWS (must be completed before `terraform init` with remote backend):**
1. Create a private S3 bucket for Terraform state (enable versioning).
2. Create a DynamoDB table for state lock with partition key `LockID` (type: String).
3. Replace placeholders in `terraform/backend.tf`:
   - `REPLACE_WITH_YOUR_TF_STATE_BUCKET`
   - `REPLACE_WITH_YOUR_AWS_REGION`
   - `REPLACE_WITH_YOUR_TF_LOCK_TABLE`
4. Run `terraform init` from the `terraform` folder to initialize the backend.

### 4. IAM Module (`modules/iam`) ✅ DONE
Implement least-privilege IAM resources for Lambda:
- Lambda execution role with trust policy for `lambda.amazonaws.com`.
- Attach `AWSLambdaBasicExecutionRole`.
- Add custom policy only for required services (specific S3 objects, KMS decrypt if needed, etc.).

Outputs:
- `lambda_execution_role_arn`

**Todo from SUNEESH in AWS (for Stage 4):**
1. Decide DEV naming prefix value for IAM resources (example: `tf-auto-dev`).
2. Confirm DEV artifact bucket name for Lambda read access policy.
3. Confirm DEV artifact key prefix (example: `lambda/dev/`) to keep S3 access least-privilege.
4. If KMS is used, provide DEV KMS key ARN(s); otherwise keep `kms_key_arns = []`.

### 5. Artifact Reference Module (`modules/s3_artifact`) ✅ DONE
Define and validate artifact inputs:
- `artifact_bucket`
- `artifact_key`
- `artifact_version` (recommended)
- Optional layer artifact key/version

Use immutable S3 object versions so each deployment is reproducible.

**Todo from SUNEESH in AWS (for Stage 5):**
1. Keep DEV artifact in root path with key `weather-lambda-0.1.jar` (current value provided by SUNEESH).
2. Use GitHub secret `S3_BUCKET_NAME` as the `artifact_bucket` source in workflow/vars.
3. After uploading artifact, copy and set `artifact_version` (S3 Version ID) in DEV tfvars.
4. Convert/package Java artifact to Lambda-supported deployment package format before function deployment (zip-based package recommended).

### 6. Lambda Layer Module (`modules/lambda_layer`) ✅ DONE
Create a Lambda layer from S3 artifact:
- `aws_lambda_layer_version` with `s3_bucket`, `s3_key`, `s3_object_version`
- Set compatible runtimes/architectures

Outputs:
- `lambda_layer_arn`

**Todo from SUNEESH in AWS (for Stage 6 - Optional):**
1. **If not using a Lambda layer:** No action required (layers are optional).
2. **If using a Lambda layer:**
   - Package layer files into a `.zip` following AWS structure (e.g., `java/lib/` for Java).
   - Upload the `.zip` to your S3 artifact bucket with versioning enabled.
   - Note the S3 key (`layer_artifact_key`) and version ID (`layer_artifact_version`) for use in `dev.tfvars`.

### 7. Lambda Function Module (`modules/lambda_function`) ✅ DONE
Deploy Lambda from S3 artifact and attach layer:
- `aws_lambda_function` with S3 bucket/key/version
- Attach IAM role ARN from IAM module
- Attach layer ARN output from layer module
- Configure runtime, handler, memory, timeout, architecture
- Add CloudWatch log group retention

Outputs:
- `lambda_function_name`
- `lambda_function_arn`
- `lambda_version`

**Todo from SUNEESH in AWS (for Stage 7):**
1. Confirm handler string matching the application class and method (e.g. `com.example.Handler::handleRequest`).
2. Confirm desired runtime (`java17` or `java21` for Java applications) and architecture (`x86_64` or `arm64`).
3. Set appropriate memory size and timeout based on workload needs.
### 8. Root Module Wiring ✅ DONE
In root `main.tf`:
1. Call `iam` module
2. Resolve S3 artifact references
3. Call `lambda_layer` module
4. Call `lambda_function` module with role ARN and layer ARN

**Todo from SUNEESH in AWS (for Stage 8):**
1. Decide whether `enable_layer` should be `true` or `false` for DEV (set to `false` if your jar contains all dependencies).
2. Identify any environment variables your Lambda code expects at runtime (e.g., `SPRING_PROFILES_ACTIVE`, config values).
3. Confirm common tags to attach to all AWS resources (e.g. `Project = "tf-auto-deploy"`, `Owner = "suneesh"`).

### 9. Environment Configuration
For each environment (`dev`, `stage`, `prod`):
- Use separate `*.tfvars`
- Set function name, artifact key, and artifact version
- Keep environment values isolated

**Implementation scope update:**
- `dev` -> implement now
- `stage`/`test` -> later implementation scope
- `prod` -> later implementation scope

### 10. CI/CD Integration
Use GitHub Actions workflow to run:
1. `terraform init`
2. `terraform fmt -check`
3. `terraform validate`
4. `terraform plan`
5. `terraform apply` (protected branch/manual approval)

### 11. Definition of Done (Terraform Side)
- Terraform creates Lambda function, role, and layer.
- Deployment uses S3 object versions.
- Environments deploy independently via tfvars.
- Outputs provide function and layer identifiers.

---

## Section 2: Steps to Do in AWS Environment (Beginner Friendly)

This section explains exactly what you should prepare in AWS before Terraform deploys successfully.

### Step 1: Choose AWS Region
Pick one region (example: `eu-central-1`) and use the same region everywhere:
- S3 artifact bucket
- Lambda function
- Terraform deployment credentials

Why: Mixing regions is a common beginner mistake and causes resource lookup failures.

### Step 2: Create S3 Bucket for Lambda Artifacts
In AWS Console:
1. Open **S3** -> **Create bucket**
2. Bucket name example: `my-lambda-artifacts-12345` (must be globally unique)
3. Region: same region chosen above
4. Keep **Block all public access = ON**
5. Enable **Bucket Versioning**
6. Create bucket

Why versioning matters: each uploaded zip gets a unique version ID, which Terraform can pin for safe deployments.

### Step 3: Upload Lambda Zip Artifact
1. Enter the bucket
2. Click **Upload**
3. Upload your Lambda package zip (example `function.zip`)
4. After upload, open object -> copy:
   - Object key (path/name)
   - Version ID

You will place these values into Terraform variables (`artifact_key`, `artifact_version`).

### Step 4: (Optional) Upload Layer Zip Artifact
If using a Lambda layer:
1. Upload layer zip (example `layer.zip`) to same or another private bucket
2. Copy object key and version ID
3. Put values in Terraform vars for layer artifact

### Step 5: Create IAM Role for GitHub Actions (Recommended: OIDC)
This role allows GitHub Actions to deploy without long-lived AWS keys.

1. In AWS Console, open **IAM**.
2. Add identity provider:
   - Provider type: **OpenID Connect**
   - Provider URL: `https://token.actions.githubusercontent.com`
   - Audience: `sts.amazonaws.com`
3. Create IAM role trusted by this provider.
4. In trust policy, restrict by:
   - Your GitHub org/user
   - Repository name
   - Branch (for example `main`)
5. Attach permissions required for Terraform-managed resources (start broad only for bootstrap, then reduce to least privilege).
6. Copy role ARN; set it in GitHub as `AWS_ROLE_ARN`.

Why OIDC: More secure than storing permanent access keys in GitHub secrets.

### Step 6: Prepare Terraform State Backend in AWS (Recommended)
For team-safe Terraform operations:

1. Create S3 bucket for state (different from artifact bucket):
   - Example: `my-terraform-state-12345`
   - Versioning enabled
   - Public access blocked
2. Create DynamoDB table for locks:
   - Table name example: `terraform-locks`
   - Partition key: `LockID` (String)
3. Configure backend in Terraform to use this bucket/table.

Why: prevents concurrent apply corruption and keeps state centralized.

### Step 7: Configure CloudWatch Logs Defaults
Lambda writes logs to CloudWatch automatically if execution role allows it.
Terraform should also set log retention (for example 14 or 30 days) to avoid unlimited log growth.

### Step 8: Add KMS (Only if Needed)
If you need encryption with customer-managed keys:
- Create KMS key
- Grant decrypt permissions to Lambda execution role
- Use key in Lambda environment variable encryption / S3 policies as needed

Beginners can skip this initially and add later.

### Step 9: Set GitHub Repository Variables/Secrets
In GitHub repo settings:
- Variables:
  - `AWS_REGION`
  - `AWS_ROLE_ARN` (if using OIDC)
- If not using OIDC (fallback only):
  - `AWS_ACCESS_KEY_ID` (secret)
  - `AWS_SECRET_ACCESS_KEY` (secret)

### Step 10: Validate Access Before First Real Deploy
Run workflow once with `terraform plan` only and verify:
- GitHub can assume AWS role
- Terraform can read/write backend state
- Terraform can read S3 artifact object/version

### Step 11: First Deployment Flow
1. Upload new zip to artifact bucket
2. Copy new object version ID
3. Update `dev.tfvars`
4. Trigger GitHub Action
5. Review plan
6. Apply on approved/protected branch

### Step 12: Promote to Stage and Prod Safely
- Keep separate tfvars files
- Use GitHub environments with approval gates
- Promote by changing artifact version IDs intentionally

**Note:** Stage/Test and Prod promotion steps are out of the current implementation scope and will be implemented later.

---

## Quick Checklist
- [ ] Artifact bucket exists, private, versioning enabled
- [ ] Lambda/function zip uploaded and version ID copied
- [ ] Layer zip uploaded (if needed) and version ID copied
- [ ] OIDC IAM role created and restricted to repo/branch
- [ ] Terraform state backend (S3 + DynamoDB) created
- [ ] GitHub variables/secrets configured
- [ ] Environment tfvars populated correctly
- [ ] First `plan` works before `apply`
