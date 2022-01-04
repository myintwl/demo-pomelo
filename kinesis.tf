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
    /*     columns = [
      {
        name = "key"
        type = "string"
      },
      {
        name = "value"
        type = "string"
      },
    ] */
  }
}

resource "aws_kinesis_firehose_delivery_stream" "firehose_stream" {
  name        = "${var.name}_firehose_delivery_stream"
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.kinesis_stream.arn
    role_arn           = aws_iam_role.firehose_role.arn
  }

  //refer the more s3 configuration at https://docs.aws.amazon.com/firehose/latest/APIReference/API_ExtendedS3DestinationConfiguration.html
  extended_s3_configuration {
    role_arn        = aws_iam_role.firehose_role.arn
    bucket_arn      = var.s3_bucket_arn
    buffer_size     = 100
    buffer_interval = "300"

    kms_key_arn = data.aws_kms_alias.kms_encryption.arn

    data_format_conversion_configuration {
      input_format_configuration {
        deserializer {
          hive_json_ser_de {}
        }
      }

      output_format_configuration {}
    }

    /*  schema_configuration {
      database_name = aws_glue_catalog_table.aws_glue_table.database_name
      role_arn      = aws_iam_role.firehose_role.arn
      table_name    = aws_glue_catalog_table.aws_glue_table.name
      region        = var.region
    } */
  }
}
