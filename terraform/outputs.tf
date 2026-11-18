# outputs.tf
# Outputs are the useful facts Terraform prints after it builds. Here: the
# public URL of your API, so you know where to send requests.

output "api_base_url" {
  description = "The public base URL of the API. Try: curl <url>/health"
  value       = aws_apigatewayv2_stage.default.invoke_url
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table holding the items."
  value       = aws_dynamodb_table.items.name
}

output "lambda_function_name" {
  description = "Name of the Lambda function (useful for reading logs)."
  value       = aws_lambda_function.api.function_name
}
