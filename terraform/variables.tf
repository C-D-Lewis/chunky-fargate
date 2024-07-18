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

variable "bucket" {
  type        = string
  description = "S3 bucket to read worlds and scenes from, and save renders to"
  default     = "public-files.chrislewis.me.uk"
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

variable "upload_trigger_enabled" {
  type        = bool
  description = "Whether to enable to Lambda task trigger on S3 world zip upload"
  default     = false
}

variable "email_notifications_enabled" {
  type        = bool
  description = "Whether to enable to SNS topic for email notifications"
  default     = false
}
