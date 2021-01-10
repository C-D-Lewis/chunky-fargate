data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnet_ids" "subnets" {
  vpc_id = data.aws_vpc.selected.id
}
