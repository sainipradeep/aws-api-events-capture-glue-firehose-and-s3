

resource "aws_iam_policy" "api_policy" {
  name = "api-sqs-cloudwatch-policy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "sqs:GetQueueUrl",
          "sqs:ChangeMessageVisibility",
          "sqs:ListDeadLetterSourceQueues",
          "sqs:SendMessageBatch",
          "sqs:PurgeQueue",
          "sqs:ReceiveMessage",
          "sqs:SendMessage",
          "sqs:GetQueueAttributes",
          "sqs:CreateQueue",
          "sqs:ListQueueTags",
          "sqs:ChangeMessageVisibilityBatch",
          "sqs:SetQueueAttributes"
        ],
        "Resource": var.main_queue_arn
      },
      {
        "Effect": "Allow",
        "Action": "sqs:ListQueues",
        "Resource": "*"
      }      
    ]
})
}


resource "aws_iam_role" "api_sqs_role" {
  name = "test_role"

  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    },
  ]
})

  tags = {
    Environment =  var.environment
  }
}

resource "aws_iam_role_policy_attachment" "api_exec_role" {
  role       =  aws_iam_role.api_sqs_role.name
  policy_arn =  aws_iam_policy.api_policy.arn
}

resource "aws_iam_policy" "lambda_sqs_policy" {
  name        = "lambda_policy_db"
  description = "IAM policy for lambda Being invoked by SQS"
  policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
          {
            "Action": [
                "sqs:DeleteMessage",
                "sqs:ReceiveMessage",
                "sqs:GetQueueAttributes"
            ],
            "Resource": "${var.main_queue_arn}",
            "Effect": "Allow"
        },
        {
          "Action": [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents"
          ],
          "Resource": "arn:aws:logs:*:*:*",
          "Effect": "Allow"
        },
        {
      "Action": [
        "kinesis:ListShards",
        "kinesis:ListStreams",
        "kinesis:*"
      ],
      "Resource": "arn:aws:kinesis:*:*:*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "stream:GetRecord",
        "stream:GetShardIterator",
        "stream:DescribeStream",
        "stream:*"
      ],
      "Resource": "arn:aws:stream:*:*:*",
      "Effect": "Allow"
    }
      ]
    })
}



resource "aws_iam_role" "lambda_exec_role" {
  name = "sqs-lambda-db"

  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
})

  tags = {
    Environment =  var.environment
  }
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_sqs_policy.arn
}





data "aws_caller_identity" "current" {}

resource "aws_iam_role" "firehose_role" {
  name = "${var.app_name}-firehose-role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "firehose.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  })
}

resource "aws_iam_role_policy" "read_policy" {
  name = "${var.app_name}-read-policy"
  //description = "Policy to allow reading from the ${var.stream_name} stream"
  role = "${aws_iam_role.firehose_role.id}"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "kinesis:DescribeStream",
                "kinesis:GetShardIterator",
                "kinesis:GetRecords"
            ],
            "Resource": [
              # "${aws_kinesis_stream.kinesis_stream.arn}"
                # "arn:aws:kinesis:${var.region}:${data.aws_caller_identity.current.account_id}:stream/${aws_kinesis_stream.kinesis_stream.name}"
                "arn:aws:kinesis:${var.region}:${data.aws_caller_identity.current.account_id}:stream/${var.aws_kinesis_stream_name}"

            ]
        },
        {
          "Effect": "Allow",
          "Action": [
              "s3:AbortMultipartUpload",
              "s3:GetBucketLocation",
              "s3:GetObject",
              "s3:ListBucket",
              "s3:ListBucketMultipartUploads",
              "s3:PutObject"
          ],
          "Resource": [
              "${var.s3_bucket_arn}",
          ]
      },
      {
      "Effect": "Allow",
      "Action": [
        "glue:*",
        "s3:*",
        "logs:*"
      ],
      "Resource": "*"
    }
]
})
}

