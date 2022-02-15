resource "aws_glue_catalog_database" "aws_glue_database" {
  name = "${var.glue_database_name}"
}

resource "aws_glue_catalog_table" "aws_glue_table" {
  name          = "${var.aws_glue_table_name}"
  database_name = "${aws_glue_catalog_database.aws_glue_database.name}"

  // Please refere the for more detail configuration of parameters at https://www.terraform.io/docs/providers/aws/r/glue_catalog_table.html
  parameters ={
    # classification = "parquet"
    "serialization.format" = 1
  }
  

  storage_descriptor {
    location      = "${var.s3_bucket_path}"
    input_format  = "${var.storage_input_format}"
    output_format = "${var.storage_output_format}"
    ser_de_info {
      name                  = "my-stream"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

      parameters = {
        "serialization.format" = 1
      }
    }
    columns {
        name = "user_name"
        type = "string"
      }

      columns {
        name = "email"
        type = "string"
      }
  }
}
