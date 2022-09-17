module "main" {
  source                      = "./infrastructure"
  region                      = var.region
  project_name                = var.project_name
  vpc_id                      = var.vpc_id
  bucket                      = var.bucket
  container_cpu               = var.container_cpu
  container_memory            = var.container_memory
  upload_trigger_enabled      = var.upload_trigger_enabled
  email_notifications_enabled = var.email_notifications_enabled
}

provider "aws" {
  region = var.region
}

terraform {
  required_version = "~> 0.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 3.75.2"
    }
  }

  backend "s3" {
    bucket = "chrislewis.me.uk-tfstate"
    key    = "chunky-fargate"
    region = "us-east-1"
  }
}
