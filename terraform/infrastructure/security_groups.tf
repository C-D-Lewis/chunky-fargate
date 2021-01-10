resource "aws_security_group" "service_sg" {
  name        = "${var.project_name}-sg"
  description = "Allow outbound traffic"
  vpc_id      = data.aws_vpc.selected.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
