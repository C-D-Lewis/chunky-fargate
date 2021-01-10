module "main" {
  source           = "./infrastructure"
  region           = var.region
  project_name     = var.project_name
  vpc_id           = var.vpc_id
}

provider "aws" {
  region = var.region
}

terraform {
  required_providers {
    aws = "~> 2.70"
  }

  backend "s3" {
    bucket  = "chrislewis.me.uk-tfstate"
    key     = "chunky-fargate"
    region  = "us-east-1"
  }
}
