output "main_queue_arn" {
  value = aws_sqs_queue.main_queue.arn
}


output "deadletter_queue_arn" {
  value = aws_sqs_queue.deadletter_queue.arn
}


output "main_queue_arn_name" {
  value = aws_sqs_queue.main_queue.name
}