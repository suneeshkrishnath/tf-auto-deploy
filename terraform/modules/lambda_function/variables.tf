variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "description" {
  description = "Description of what the Lambda function does"
  type        = string
  default     = null
}

variable "role_arn" {
  description = "IAM execution role ARN for Lambda"
  type        = string
}

variable "handler" {
  description = "Function entrypoint in code (e.g. com.example.Handler::handleRequest)"
  type        = string
}

variable "runtime" {
  description = "Lambda runtime identifier (e.g. java17, java21, python3.11)"
  type        = string
}

variable "memory_size" {
  description = "Amount of memory in MB the Lambda function can use at runtime"
  type        = number
  default     = 512
}

variable "timeout" {
  description = "Function execution timeout in seconds"
  type        = number
  default     = 30
}

variable "architectures" {
  description = "Instruction set architecture for Lambda function (e.g. ['x86_64'] or ['arm64'])"
  type        = list(string)
  default     = ["x86_64"]
}

variable "s3_bucket" {
  description = "S3 bucket containing the function deployment package"
  type        = string
}

variable "s3_key" {
  description = "S3 key for the function deployment package"
  type        = string
}

variable "s3_object_version" {
  description = "Optional S3 object version for immutable function deployment"
  type        = string
  default     = null
}

variable "layers" {
  description = "List of Lambda Layer Version ARNs to attach to the function"
  type        = list(string)
  default     = []
}

variable "environment_variables" {
  description = "Key-value map of environment variables available to Lambda runtime"
  type        = map(string)
  default     = {}
}

variable "log_retention_in_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "tags" {
  description = "Tags to assign to Lambda function and CloudWatch Log Group"
  type        = map(string)
  default     = {}
}
