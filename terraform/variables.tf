variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
}

variable "environment" {
  description = "Target deployment environment (e.g. dev, stage, prod)"
  type        = string
}

variable "function_name" {
  description = "Base name for the Lambda function"
  type        = string
}

variable "function_description" {
  description = "Description for the Lambda function"
  type        = string
  default     = null
}

variable "handler" {
  description = "Function entrypoint in code"
  type        = string
}

variable "runtime" {
  description = "Lambda runtime identifier"
  type        = string
}

variable "memory_size" {
  description = "Amount of memory in MB for the Lambda function"
  type        = number
  default     = 512
}

variable "timeout" {
  description = "Function execution timeout in seconds"
  type        = number
  default     = 30
}

variable "architectures" {
  description = "Instruction set architecture for Lambda function"
  type        = list(string)
  default     = ["x86_64"]
}

variable "artifact_bucket" {
  description = "S3 bucket containing Lambda deployment artifacts"
  type        = string
}

variable "artifact_key" {
  description = "S3 key for the Lambda function package"
  type        = string
}

variable "artifact_version" {
  description = "Optional S3 object version for immutable Lambda function deployment"
  type        = string
  default     = null
}

variable "artifact_key_prefix" {
  description = "S3 key prefix for IAM read access policy (example: lambda/dev/)"
  type        = string
  default     = "*"
}

variable "kms_key_arns" {
  description = "Optional KMS key ARNs for IAM decrypt policy"
  type        = list(string)
  default     = []
}

variable "enable_layer" {
  description = "Whether to create and attach a Lambda layer from S3"
  type        = bool
  default     = false
}

variable "layer_name" {
  description = "Optional name for Lambda Layer; defaults to prefix-based name"
  type        = string
  default     = null
}

variable "layer_description" {
  description = "Optional description for Lambda Layer"
  type        = string
  default     = null
}

variable "layer_artifact_key" {
  description = "Optional S3 key for Lambda Layer package"
  type        = string
  default     = null
}

variable "layer_artifact_version" {
  description = "Optional S3 object version for Lambda Layer package"
  type        = string
  default     = null
}

variable "layer_compatible_runtimes" {
  description = "List of compatible runtimes for Lambda Layer"
  type        = list(string)
  default     = null
}

variable "layer_compatible_architectures" {
  description = "List of compatible architectures for Lambda Layer"
  type        = list(string)
  default     = null
}

variable "layer_skip_destroy" {
  description = "Whether to retain old layer versions upon replacement"
  type        = bool
  default     = false
}

variable "layers" {
  description = "Additional existing Lambda Layer ARNs to attach"
  type        = list(string)
  default     = []
}

variable "environment_variables" {
  description = "Key-value map of environment variables passed to Lambda"
  type        = map(string)
  default     = {}
}

variable "log_retention_in_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
