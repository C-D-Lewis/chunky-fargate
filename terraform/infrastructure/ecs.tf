resource "aws_ecr_repository" "service_ecr" {
  name = "${var.project_name}-service-ecr"
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.project_name}-ecs-cluster"
}
