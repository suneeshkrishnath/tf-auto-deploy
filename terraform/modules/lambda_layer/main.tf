resource "aws_lambda_layer_version" "this" {
  layer_name               = var.layer_name
  description              = var.description
  s3_bucket                = var.s3_bucket
  s3_key                   = var.s3_key
  s3_object_version        = var.s3_object_version
  compatible_runtimes      = var.compatible_runtimes
  compatible_architectures = var.compatible_architectures
  skip_destroy             = var.skip_destroy
}
