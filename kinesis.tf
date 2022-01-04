resource "aws_kinesis_stream" "kinesis_stream" {
  name             = "${var.name}-kinesis-stream"
  shard_count      = var.shard_count
  retention_period = var.retention_period_kinesis

  shard_level_metrics = var.shard_level_metrics

  tags = {
    Product = local.app_name
  }
}

data "aws_kms_alias" "kms_encryption" {
  name = "alias/aws/s3"
}

resource "aws_glue_catalog_database" "aws_glue_database" {
  name = "${var.name}-glue-database"
}


resource "aws_glue_catalog_table" "aws_glue_table" {
  name          = "${var.name}-glue-table"
  database_name = aws_glue_catalog_database.aws_glue_database.name
  storage_descriptor {
    location      = var.s3_bucket_path
    input_format  = var.storage_input_format
    output_format = var.storage_output_format
  }
}

resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  name        = "terraform-kinesis-firehose-extended-s3-test-stream"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.bucket.arn

    processing_configuration {
      enabled = "true"

      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${aws_lambda_function.lambda_sqs.arn}:$LATEST"
        }
      }
    }
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = "tf-test-bucket"
  acl    = "private"
}