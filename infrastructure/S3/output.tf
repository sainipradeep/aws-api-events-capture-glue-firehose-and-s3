output "s3_bucket_arn" {
  value = aws_s3_bucket.firehose_delivery_bucket.arn
}



output "s3_bucket_name" {
  value = aws_s3_bucket.firehose_delivery_bucket.id
  
}