resource "aws_cloudwatch_log_group" "log_group" {
  name = "/aws/ecs/${var.project_name}-logs"
}
