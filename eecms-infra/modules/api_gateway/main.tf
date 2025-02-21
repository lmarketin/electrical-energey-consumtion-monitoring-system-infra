resource "aws_apigatewayv2_api" "apigw" {
  name          = "api_gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_vpc_link" "vpc_link_apigw_to_alb" {
  name               = "vpc_link_apigw_to_alb"
  security_group_ids = []//TODO SG for my IP
  subnet_ids         = [var.private_subnet_1_id, var.private_subnet_2_id]
}

resource "aws_apigatewayv2_integration" "apigw_integration" {
  api_id             = aws_apigatewayv2_api.apigw.id
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"
  integration_uri    = var.lb_listener_arn

  connection_id      = aws_apigatewayv2_vpc_link.vpc_link_apigw_to_alb.id
  connection_type    = "VPC_LINK"
  description        = "VPC integration"

  depends_on         = [aws_apigatewayv2_vpc_link.vpc_link_apigw_to_alb, aws_apigatewayv2_api.apigw]
 }

resource "aws_apigatewayv2_route" "apigw_route" {
  api_id    = aws_apigatewayv2_api.apigw.id
  route_key = "$default"
  target = "integrations/${aws_apigatewayv2_integration.apigw_integration.id}"

  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.lambda_auth.id

  depends_on  = [aws_apigatewayv2_integration.apigw_integration]
}

resource "aws_apigatewayv2_stage" "apigw_stage" {
  api_id = aws_apigatewayv2_api.apigw.id
  name   = "$default"
  auto_deploy = true
  depends_on  = [aws_apigatewayv2_api.apigw]

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

resource "aws_apigatewayv2_authorizer" "lambda_auth" {
  api_id           = aws_apigatewayv2_api.apigw.id
  authorizer_type  = "REQUEST"
  name             = "ApiKeyAuthorizer"
  authorizer_uri   = "arn:aws:apigateway:eu-central-1:lambda:path/2015-03-31/functions/${var.request_authorizer_lambda_arn}/invocations"
  authorizer_payload_format_version = "1.0"
  identity_sources = ["$request.header.x-api-key"]
  authorizer_result_ttl_in_seconds = 0 # Disable caching
}
