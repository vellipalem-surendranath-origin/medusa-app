variable "aws_region" {
  description = "The AWS region to deploy to"
  default     = "ap-south-1"
}

# Variables for DB credentials
variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "subnet_id" {}

variable "vpc_id" {}
