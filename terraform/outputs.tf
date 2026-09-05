output "lambda_function_name" {
  description = "Name of the deployed Lambda function"
  value       = module.lambda_function.lambda_function_name
}

output "lambda_function_arn" {
  description = "ARN of the deployed Lambda function"
  value       = module.lambda_function.lambda_function_arn
}

output "lambda_version" {
  description = "Latest published version of the deployed Lambda function"
  value       = module.lambda_function.lambda_version
}

output "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = module.iam.lambda_execution_role_arn
}

output "lambda_layer_arn" {
  description = "ARN of the deployed Lambda layer version, if enabled"
  value       = var.enable_layer ? module.lambda_layer[0].lambda_layer_arn : null
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group for Lambda"
  value       = module.lambda_function.cloudwatch_log_group_name
}
