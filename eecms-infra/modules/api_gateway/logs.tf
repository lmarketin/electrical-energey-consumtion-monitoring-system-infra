resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/eecms"
  retention_in_days = 5
}
