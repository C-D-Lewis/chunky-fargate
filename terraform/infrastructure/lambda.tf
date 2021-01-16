locals {
  lambda_function_name = "${var.project_name}-upload-function"
}

resource "aws_lambda_function" "upload_function" {
  count = var.upload_trigger_enabled ? 1 : 0

  filename         = "../upload-function.zip"
  function_name    = local.lambda_function_name
  role             = aws_iam_role.upload_function_role[0].arn
  handler          = "upload-function.handler"
  runtime          = "nodejs12.x"
  source_code_hash = filebase64sha256("../upload-function.zip")
}
