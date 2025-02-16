output "request_authorizer_lambda_arn" {
  value = aws_lambda_function.request_authorizer.arn
}

output "request_authorizer_lambda_invoke_arn" {
  value = aws_lambda_function.request_authorizer.invoke_arn
}

output "request_authorizer_iam_role_arn" {
  value = aws_iam_role.request_authorizer.arn
}