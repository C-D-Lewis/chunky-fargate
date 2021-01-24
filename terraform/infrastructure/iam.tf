resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-task-execution-role"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role" "ecs_task_role" {
  name        = "${var.project_name}-task-role"
  description = "Allow putting output file in the bucket"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs_task_role_policy" {
  name = "${var.project_name}-task-role-policy"
  role = aws_iam_role.ecs_task_role.id

  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::${var.bucket}/*",
        "arn:aws:s3:::${var.bucket}"
      ]
    }
  ]
}
EOF  
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "upload_function_role" {
  count = var.upload_trigger_enabled ? 1 : 0

  name = "${var.project_name}-upload-function-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_lambda_permission" "allow_bucket" {
  count = var.upload_trigger_enabled ? 1 : 0

  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upload_function[0].arn
  principal     = "s3.amazonaws.com"
  source_arn    = data.aws_s3_bucket.selected.arn
}

resource "aws_iam_policy" "lambda_policy" {
  count = var.upload_trigger_enabled ? 1 : 0

  name        = "${var.project_name}-lambda-policy"
  path        = "/"
  description = "IAM policy for the bucket upload lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:*:*:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "${data.aws_s3_bucket.selected.arn}",
        "${data.aws_s3_bucket.selected.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecs:*",
        "ecr:*",
        "ec2:*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  count = var.upload_trigger_enabled ? 1 : 0

  role       = aws_iam_role.upload_function_role[0].name
  policy_arn = aws_iam_policy.lambda_policy[0].arn
}