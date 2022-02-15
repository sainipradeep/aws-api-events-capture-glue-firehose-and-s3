output "lambda_exec_role" {
    value = aws_iam_role.lambda_exec_role.arn
}
output "api_exec_role" {
    value = aws_iam_role_policy_attachment.api_exec_role
}

output "lambda_role_policy" {
    value = aws_iam_role_policy_attachment.lambda_role_policy
}

output "api_sqs_arn" {
    value = aws_iam_role.api_sqs_role.arn
}

output "firehose_role_arn" {
    value = aws_iam_role.firehose_role.arn

}