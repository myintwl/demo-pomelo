variable "environment" {
  description = "Env"
  default     = "dev"
}

variable "name" {
  description = "Application Name"
  type        = string
}

locals {
  description = "Aplication Name"
  app_name    = "${var.name}-${var.environment}"
}

variable "region" {
  default = "ap-southeast-1"
}

variable "lambda_name" {
  description = "Name for lambda function"
  default     = "lambda"
}

variable "secret_key" {
  description = "secret key for AWS Account"
}

variable "access_key" {
  description = "access key for AWS Account"
}