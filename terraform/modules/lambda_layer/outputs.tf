output "lambda_layer_arn" {
  description = "ARN of the Lambda Layer with version"
  value       = aws_lambda_layer_version.this.arn
}

output "layer_arn" {
  description = "ARN of the Lambda Layer without version"
  value       = aws_lambda_layer_version.this.layer_arn
}

output "version" {
  description = "Version of the Lambda Layer"
  value       = aws_lambda_layer_version.this.version
}
