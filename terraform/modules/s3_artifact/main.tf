locals {
  artifact_reference = {
    bucket  = var.artifact_bucket
    key     = var.artifact_key
    version = var.artifact_version
  }

  layer_reference = var.layer_artifact_key == null ? null : {
    bucket  = var.artifact_bucket
    key     = var.layer_artifact_key
    version = var.layer_artifact_version
  }
}
