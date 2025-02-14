resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/CustomerEnergyAPI"
  retention_in_days = 5  # Free tier allows log storage, keeping it for 7 days is cost-effective.
}

resource "aws_iam_role" "api_gateway_logging_role" {
  name = "APIGatewayLoggingRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "apigateway.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "api_gateway_logging_policy" {
  name        = "APIGatewayLoggingPolicy"
  description = "Policy to allow API Gateway to write logs to CloudWatch"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
      Effect   = "Allow"
      Resource = "${aws_cloudwatch_log_group.api_gateway.arn}:*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway_logging_attach" {
  role       = aws_iam_role.api_gateway_logging_role.name
  policy_arn = aws_iam_policy.api_gateway_logging_policy.arn
}




resource "aws_apigatewayv2_api" "api_gw" {
  name          = "api_gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_vpc_link" "vpclink_apigw_to_alb" {
  name               = "vpclink_apigw_to_alb"
  security_group_ids = []
  subnet_ids         = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_1.id]
}

resource "aws_apigatewayv2_integration" "apigw_integration" {
  api_id             = aws_apigatewayv2_api.api_gw.id
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"
  //integration_uri    = "arn:aws:elasticloadbalancing:eu-central-1:820242920924:listener/app/alb/0e56fac8ba335584/14db300000c18d04"
  integration_uri  = aws_lb_listener.listener.arn

  connection_id      = aws_apigatewayv2_vpc_link.vpclink_apigw_to_alb.id
  connection_type    = "VPC_LINK"
  description        = "VPC integration"

  depends_on      = [aws_apigatewayv2_vpc_link.vpclink_apigw_to_alb, aws_apigatewayv2_api.api_gw, aws_lb_listener.listener]
 }

resource "aws_apigatewayv2_route" "apigw_route" {
  api_id    = aws_apigatewayv2_api.api_gw.id
  route_key = "$default"//"ANY /"//"ANY /{proxy+}"
  target = "integrations/${aws_apigatewayv2_integration.apigw_integration.id}"

  authorization_type = "CUSTOM"//-
  authorizer_id      = aws_apigatewayv2_authorizer.lambda_auth.id//-

  depends_on  = [aws_apigatewayv2_integration.apigw_integration]
}

resource "aws_apigatewayv2_stage" "apigw_stage" {
  api_id = aws_apigatewayv2_api.api_gw.id
  name   = "$default"
  auto_deploy = true
  depends_on  = [aws_apigatewayv2_api.api_gw]

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip            = "$context.identity.sourceIp"
      requestTime   = "$context.requestTime"
      httpMethod    = "$context.httpMethod"
      routeKey      = "$context.routeKey"
      status        = "$context.status"
      integrationLatency = "$context.integrationLatency"
      responseLatency = "$context.responseLatency"
    })
  }
}

module "request_authorizer" {
  source = "./lambda/request_authorizer"
}

resource "aws_apigatewayv2_authorizer" "lambda_auth" {
  api_id           = aws_apigatewayv2_api.api_gw.id
  authorizer_type  = "REQUEST"
  name             = "ApiKeyAuthorizer"
  authorizer_uri   = "arn:aws:apigateway:eu-central-1:lambda:path/2015-03-31/functions/${module.request_authorizer.request_authorizer_lambda_arn}/invocations"
  authorizer_payload_format_version = "1.0"
  identity_sources = ["$request.header.x-api-key"]
}
