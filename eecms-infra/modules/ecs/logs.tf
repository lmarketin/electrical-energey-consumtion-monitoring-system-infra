resource "aws_cloudwatch_log_group" "eecms_cluster_log_group" {
  name              = "/aws/ecs/eecms"
  retention_in_days = 5
}