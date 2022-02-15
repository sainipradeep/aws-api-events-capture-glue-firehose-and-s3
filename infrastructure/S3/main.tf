

provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "firehose_delivery_bucket" {
  bucket = "${var.app_name}-firehose-delivery-bucket"
  # region = var.region
  acl    = "private"

  tags = {
    Environment = var.environment
  }
}
