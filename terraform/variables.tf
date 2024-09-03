variable "aws_region" {
  description = "The AWS region to deploy to"
  default     = "us-east-1"
}

# Variables for DB credentials
variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}
