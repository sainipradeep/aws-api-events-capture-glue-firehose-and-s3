resource "aws_sqs_queue" "main_queue" {
  name                      = var.queue_name
  delay_seconds             = var.delay_seconds
  max_message_size          = var.max_message_size
  message_retention_seconds = var.retention_period
  visibility_timeout_seconds= var.visibility_timeout
#   receive_wait_time_seconds = var.receive_wait_time_seconds
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.deadletter_queue.arn
    maxReceiveCount     = 4
  })
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = ["${aws_sqs_queue.deadletter_queue.arn}"]
  })

  tags = {
    Environment = var.environment
  }
}



resource "aws_sqs_queue" "deadletter_queue" {
  name                      = "deadletter_queue"
  delay_seconds             = var.delay_seconds
  message_retention_seconds = var.retention_period
  visibility_timeout_seconds        = var.visibility_timeout
#   receive_wait_time_seconds = var.receive_wait_time_seconds

  tags = {
    Environment = var.environment
  }
}

