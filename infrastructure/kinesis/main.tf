resource "aws_kinesis_stream" "kinesis_stream" {
  name             = "${var.app_name}-kinesis-stream"
  shard_count      = 1
  retention_period = 48

  shard_level_metrics = [
    "IncomingBytes",
    "IncomingRecords",
    "OutgoingBytes",
    "OutgoingRecords",
  ]

  tags = {
    Environment = var.environment
  }
}

data "aws_kms_alias" "kms_encryption" {
  name = "alias/aws/s3"
}

resource "aws_kinesis_firehose_delivery_stream" "firehose_stream" {
  name        = var.aws_kinesis_stream_name
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = "${aws_kinesis_stream.kinesis_stream.arn}"
    role_arn           = "${var.firehose_role_arn}"
  }

  //refer the more s3 configuration at https://docs.aws.amazon.com/firehose/latest/APIReference/API_ExtendedS3DestinationConfiguration.html
  extended_s3_configuration {
    role_arn        = "${var.firehose_role_arn}"
    bucket_arn      = "${var.s3_bucket_arn}"
    buffer_size     = 100
    buffer_interval = "60"

    kms_key_arn = "${data.aws_kms_alias.kms_encryption.arn}"

    data_format_conversion_configuration {
      input_format_configuration {
        deserializer {
          hive_json_ser_de {}
        }
      }

      output_format_configuration {
        serializer {
          parquet_ser_de {}
        }
      }

      schema_configuration {
        database_name = "${var.glue_database_name}"
        role_arn      = "${var.firehose_role_arn}"
        table_name    = "${var.aws_glue_table_name}"
        region        = "${var.region}"
      }
    }
  }
}