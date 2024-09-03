variable "aws_region" {
  description = "The AWS region to deploy to"
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "The VPC ID where ECS services will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where ECS services will be deployed"
  type        = list(string)
}
