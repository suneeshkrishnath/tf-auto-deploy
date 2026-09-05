variable "name_prefix" {
  description = "Prefix used for naming IAM resources"
  type        = string
}

variable "artifact_bucket" {
  description = "S3 bucket containing Lambda artifacts"
  type        = string
}

variable "artifact_key_prefix" {
  description = "S3 key prefix Lambda can read (example: lambda/dev/)"
  type        = string
  default     = "*"
}

variable "kms_key_arns" {
  description = "Optional KMS key ARNs Lambda can decrypt with"
  type        = list(string)
  default     = []
}
