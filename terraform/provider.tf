provider "aws" {
  region = var.aws_region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

terraform {
  backend "s3" {
    bucket         = "medusa-terraform-state-bucket"
    key            = "medusa-ecs-terraform.tfstate"
    region         = var.aws_region
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}
