resource "aws_cloudwatch_log_group" "eecss_cluster_log_group" {
  name              = "/aws/ecs/eecss"
  retention_in_days = 5
}