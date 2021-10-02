data "aws_s3_bucket" "selected" {
  bucket = var.bucket
}

resource "aws_s3_bucket_object" "tasks_placeholder" {
  bucket  = data.aws_s3_bucket.selected.id
  key     = "chunky-fargate/tasks/drop-tasks-here"
  content = "Will trigger a Fargate task if world name is included in task file name."
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  count = var.upload_trigger_enabled ? 1 : 0

  bucket = data.aws_s3_bucket.selected.id

  # When a world is uploaded
  lambda_function {
    lambda_function_arn = aws_lambda_function.upload_function[0].arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "chunky-fargate/worlds/"
    filter_suffix       = ".zip"
  }

  # When a task is uploaded
  lambda_function {
    lambda_function_arn = aws_lambda_function.upload_function[0].arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "chunky-fargate/tasks/"
    filter_suffix       = ".json"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}
