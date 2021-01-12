resource "aws_ecr_repository" "service_ecr" {
  name = "${var.project_name}-service-ecr"
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.project_name}-ecs-cluster"
}

resource "aws_ecs_task_definition" "task_definition" {
  family                   = "${var.project_name}-td"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  network_mode             = "awsvpc"
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  requires_compatibilities = ["FARGATE"]

  container_definitions = <<TASK_DEFINITION
[
  { 
    "name": "${var.project_name}-container-def",
    "image": "${aws_ecr_repository.service_ecr.repository_url}:latest",
    "cpu": ${var.container_cpu},
    "memory": ${var.container_memory},
    "logConfiguration": { 
      "logDriver": "awslogs",
      "options": { 
        "awslogs-group" : "/aws/ecs/${var.project_name}-logs",
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
TASK_DEFINITION
}
