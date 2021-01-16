resource "aws_lambda_function" "upload_function" {
  filename         = "function.zip"
  function_name    = "${var.project_name}-upload-function"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "exports.handler"
  runtime          = "nodejs12.x"
  source_code_hash = filebase64sha256("function.zip")
}
