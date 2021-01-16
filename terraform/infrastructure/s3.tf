data "aws_s3_bucket" "selected" {
  bucket = var.bucket
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  count = var.upload_trigger_enabled ? 1 : 0

  bucket = data.aws_s3_bucket.selected.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.upload_function[0].arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "chunky-fargate/worlds/"
    filter_suffix       = ".zip"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}
