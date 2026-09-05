variable "artifact_bucket" {
  description = "S3 bucket containing Lambda deployment artifact"
  type        = string
}

variable "artifact_key" {
  description = "S3 object key for Lambda deployment artifact (zip/jar path in bucket)"
  type        = string
}

variable "artifact_version" {
  description = "Optional S3 object version ID for immutable deployments"
  type        = string
  default     = null
}

variable "layer_artifact_key" {
  description = "Optional S3 object key for Lambda layer artifact"
  type        = string
  default     = null
}

variable "layer_artifact_version" {
  description = "Optional S3 object version ID for Lambda layer artifact"
  type        = string
  default     = null
}
