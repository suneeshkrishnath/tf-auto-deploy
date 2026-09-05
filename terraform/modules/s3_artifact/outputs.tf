output "artifact_bucket" {
  description = "S3 bucket for Lambda deployment artifact"
  value       = local.artifact_reference.bucket
}

output "artifact_key" {
  description = "S3 key for Lambda deployment artifact"
  value       = local.artifact_reference.key
}

output "artifact_version" {
  description = "S3 object version for Lambda deployment artifact"
  value       = local.artifact_reference.version
}

output "layer_artifact_bucket" {
  description = "S3 bucket for Lambda layer artifact"
  value       = local.layer_reference == null ? null : local.layer_reference.bucket
}

output "layer_artifact_key" {
  description = "S3 key for Lambda layer artifact"
  value       = local.layer_reference == null ? null : local.layer_reference.key
}

output "layer_artifact_version" {
  description = "S3 object version for Lambda layer artifact"
  value       = local.layer_reference == null ? null : local.layer_reference.version
}
