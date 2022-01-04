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

variable "retention_period" {
  description = "Time (in seconds) "
  type        = number
  default     = 86400
}
variable "receive_wait" {
  description = "Time (in seconds)"
  type        = number
  default     = 10
}

variable "max_size" {
  type    = number
  default = 262144
}

variable "delay" {
  type    = number
  default = 0
}

variable "secret_key" {
  description = "secret key for AWS Account"
}

variable "access_key" {
  description = "access key for AWS Account"
}

//aws_kinesis_stream variable
variable "shard_count" {
  description = "The number of shards that the stream will use."
  default     = "1"
}

variable "retention_period_kinesis" {
  description = "Length of time data records are accessible after they are added to the stream."
  default     = "48"
}

variable "shard_level_metrics" {
  type        = list(string)
  description = "A list of shard-level CloudWatch metrics which can be enabled for the stream."
  default     = []
}

variable "s3_bucket_arn" {
  description = "s3 bucket arn where kinesis firehose put data."
  default     = ""
}

variable "s3_bucket_path" {
  description = "s3 bucket path where kinesis firehose put data."
  default     = ""
}

variable "storage_input_format" {
  description = "storage input format for aws glue for parcing data"
  default     = ""
}

variable "storage_output_format" {
  description = "storage output format for aws glue for parcing data"
  default     = ""
}