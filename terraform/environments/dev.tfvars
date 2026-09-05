# Deployment Region & Environment
aws_region  = "eu-central-1"
environment = "dev"

# Lambda Function Configuration
function_name        = "weather-service"
function_description = "Weather service Lambda deployed via Terraform and GitHub Actions"
runtime              = "java17"
handler              = "com.example.weather.StreamLambdaHandler::handleRequest"
memory_size          = 1024
timeout              = 30
architectures        = ["x86_64"]

# S3 Artifact Source
# Set your private S3 bucket containing the Lambda artifact
artifact_bucket  = "REPLACE_WITH_YOUR_ARTIFACT_BUCKET"
artifact_key     = "weather-lambda-0.1.jar"
# S3 object version ID for reproducible deployments (copy from S3 object properties after upload)
artifact_version = null

# IAM & Security
artifact_key_prefix = "weather-lambda*"
kms_key_arns        = []

# Lambda Layer Configuration (disabled by default for DEV)
enable_layer = false

# Runtime Environment Variables
environment_variables = {
  ENVIRONMENT = "dev"
  LOG_LEVEL   = "INFO"
}

# CloudWatch Logs Retention (days)
log_retention_in_days = 14

# Resource Tags
tags = {
  Environment = "dev"
  Project     = "tf-auto-deploy"
  ManagedBy   = "Terraform"
}
