locals {
  common_tags = merge(
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )
}

# 1. IAM Execution Role & Policy
module "iam" {
  source = "./modules/iam"

  name_prefix         = "${var.environment}-${var.function_name}"
  artifact_bucket     = var.artifact_bucket
  artifact_key_prefix = var.artifact_key_prefix
  kms_key_arns        = var.kms_key_arns
}

# 2. S3 Artifact Resolution
module "s3_artifact" {
  source = "./modules/s3_artifact"

  artifact_bucket        = var.artifact_bucket
  artifact_key           = var.artifact_key
  artifact_version       = var.artifact_version
  layer_artifact_key     = var.layer_artifact_key
  layer_artifact_version = var.layer_artifact_version
}

# 3. Optional Lambda Layer
module "lambda_layer" {
  count  = var.enable_layer ? 1 : 0
  source = "./modules/lambda_layer"

  layer_name               = var.layer_name != null ? var.layer_name : "${var.environment}-${var.function_name}-layer"
  description              = var.layer_description
  s3_bucket                = module.s3_artifact.layer_artifact_bucket
  s3_key                   = module.s3_artifact.layer_artifact_key
  s3_object_version        = module.s3_artifact.layer_artifact_version
  compatible_runtimes      = var.layer_compatible_runtimes
  compatible_architectures = var.layer_compatible_architectures
  skip_destroy             = var.layer_skip_destroy
}

# 4. Lambda Function
module "lambda_function" {
  source = "./modules/lambda_function"

  function_name         = "${var.environment}-${var.function_name}"
  description           = var.function_description
  role_arn              = module.iam.lambda_execution_role_arn
  handler               = var.handler
  runtime               = var.runtime
  memory_size           = var.memory_size
  timeout               = var.timeout
  architectures         = var.architectures
  s3_bucket             = module.s3_artifact.artifact_bucket
  s3_key                = module.s3_artifact.artifact_key
  s3_object_version     = module.s3_artifact.artifact_version
  layers                = concat(var.enable_layer ? [module.lambda_layer[0].lambda_layer_arn] : [], var.layers)
  environment_variables = var.environment_variables
  log_retention_in_days = var.log_retention_in_days
  tags                  = local.common_tags
}
