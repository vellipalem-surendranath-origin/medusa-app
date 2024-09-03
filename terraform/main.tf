provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./vpc"
}

module "ecs" {
  source = "./ecs"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.subnet_ids
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "ecs_cluster_id" {
  value = module.ecs.cluster_id
}
