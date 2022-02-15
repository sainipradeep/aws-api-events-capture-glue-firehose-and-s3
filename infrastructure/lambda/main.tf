resource "aws_lambda_permission" "allows_sqs_to_trigger_lambda" {
  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_sqs.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = var.main_queue_arn
}

# Trigger lambda on message to SQS
resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  batch_size       = 1
  event_source_arn =  var.main_queue_arn
  enabled          = true
  function_name    =  aws_lambda_function.lambda_sqs.arn
}


data "archive_file" "lambda_with_dependencies" {
  source_dir  = "./lambda-function-code/"
  output_path = "lambda/lambda-function.zip"
  type        = "zip"
}


resource "aws_lambda_function" "lambda_sqs" {
  function_name    = "TestingFunction"
  handler          = "handler.lambda_handler"
  role             = var.lambda_exec_role
  runtime          = "nodejs14.x"

  filename         = data.archive_file.lambda_with_dependencies.output_path
  source_code_hash = data.archive_file.lambda_with_dependencies.output_base64sha256

  timeout          = 30
  memory_size      = 128
    #aws_iam_role_policy_attachment.lambda_role_policy

  depends_on = [
    var.lambda_role_policy
  ]
}

