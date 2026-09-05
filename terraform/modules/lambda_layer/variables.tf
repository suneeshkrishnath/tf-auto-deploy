variable "layer_name" {
  description = "Name of the Lambda Layer"
  type        = string
}

variable "description" {
  description = "Description of what your Lambda Layer does"
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "S3 bucket containing the Lambda layer deployment artifact"
  type        = string
}

variable "s3_key" {
  description = "S3 key for the Lambda layer deployment artifact (zip file)"
  type        = string
}

variable "s3_object_version" {
  description = "Optional S3 object version for immutable layer deployment"
  type        = string
  default     = null
}

variable "compatible_runtimes" {
  description = "List of Lambda runtimes this layer is compatible with"
  type        = list(string)
  default     = null
}

variable "compatible_architectures" {
  description = "List of architectures this layer is compatible with (e.g., x86_64, arm64)"
  type        = list(string)
  default     = null
}

variable "skip_destroy" {
  description = "Whether to retain the old version of a previously applied layer"
  type        = bool
  default     = false
}
