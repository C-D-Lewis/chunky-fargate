variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Project name for all resources"
  default     = "chunky-fargate"
}

variable "vpc_id" {
  type        = string
  description = "VPC to deploy into"
  default     = "vpc-c3b70bb9"
}

variable "output_bucket" {
  type        = string
  description = "Output S3 bucket to save renders to"
}

variable "container_cpu" {
  type        = string
  description = "Container CPU units"
  default     = 4096
}

variable "container_memory" {
  type        = string
  description = "Container memory units"
  default     = 8192
}
