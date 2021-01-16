resource "aws_cloudwatch_log_group" "fargate_group" {
  name = "/aws/ecs/${var.project_name}-logs"
}

resource "aws_cloudwatch_log_group" "upload_function_group" {
  count = var.upload_trigger_enabled ? 1 : 0

  name              = "/aws/lambda/${local.lambda_function_name}"
  retention_in_days = 14
}
