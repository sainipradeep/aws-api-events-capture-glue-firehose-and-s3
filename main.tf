module "message_queue" {
    source                              = "./infrastructure/sqs"
    queue_name                          = local.queue_name
    environment                         = local.environment
}
module "S3" {
    source                              = "./infrastructure/S3"
    region                              = local.region
    environment                         = local.environment
    app_name                            = local.app_name

}

module "policies" {
    source                              = "./infrastructure/policies"
    main_queue_arn                      = module.message_queue.main_queue_arn
    environment                         = local.environment
    app_name                            = local.app_name
    region                              = local.region
    s3_bucket_arn                       = module.S3.s3_bucket_arn
    aws_kinesis_stream_name             = local.aws_kinesis_stream_name
}

module "lambda" {
    source                              = "./infrastructure/lambda"
    lambda_exec_role                    = module.policies.lambda_exec_role
    lambda_role_policy                  = module.policies.lambda_role_policy
    main_queue_arn                      = module.message_queue.main_queue_arn
}

module "api-gateway" {
    source                              = "./infrastructure/api-gateway"
    api_sqs_arn                         = module.policies.api_sqs_arn
    main_queue_arn                      = module.message_queue.main_queue_arn
    main_queue_arn_name                 = module.message_queue.main_queue_arn_name
    region                              = local.region
    api_exec_role                       = module.policies.api_exec_role
    environment                         = local.environment
}

module "kinesis" {
    source                              = "./infrastructure/kinesis"
    environment                         = local.environment
    aws_kinesis_stream_name             = local.aws_kinesis_stream_name
    aws_glue_table_name                 = local.aws_glue_table_name
    firehose_role_arn                   = module.policies.firehose_role_arn
    s3_bucket_arn                       = module.S3.s3_bucket_arn
    app_name                            = local.app_name
    region                              = local.region
    glue_database_name                  = local.glue_database_name
}

module "glue" {
    source                              = "./infrastructure/glue"
    aws_s3_bucket                       = module.S3.s3_bucket_name
    environment                         = local.environment
    # s3_bucket_path                    = "s3://${module.S3.s3_bucket_name}/event-streams/my-stream"
    s3_bucket_path                      = "s3://${module.S3.s3_bucket_name}"
    storage_input_format                = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    storage_output_format               = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"
    app_name                            = local.app_name
    glue_database_name                  = local.glue_database_name
    aws_glue_table_name                 = local.aws_glue_table_name

}