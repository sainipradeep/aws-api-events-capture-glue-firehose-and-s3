locals {
  environment                                           = "testing"
  region                                                = "ap-south-1"
  queue_name                                            = "main-queue"
  app_name                                              = "testing"
  aws_glue_table_name                                   = "${local.app_name}-glue-table"
  glue_database_name                                    = "${local.app_name}-glue-database"
  aws_kinesis_stream_name                               = "${local.app_name}-kinesis-stream"
}

provider "aws" {
  region                                                = local.region
}
