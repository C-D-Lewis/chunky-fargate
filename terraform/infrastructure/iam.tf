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
      "Resource": ["arn:aws:s3:::${var.output_bucket}/*"]
    }
  ]
}
EOF  
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
