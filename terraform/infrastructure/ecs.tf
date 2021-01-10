resource "aws_ecr_repository" "server_ecr" {
  name = "${var.project_name}-server-ecr"
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.project_name}-ecs-cluster"
}
