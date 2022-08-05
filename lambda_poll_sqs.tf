data "archive_file" "zipit2" {
  type        = "zip"
  source_file = "handler_pollSQS.py"
  output_path = "handler_pollSQS.zip"
}


resource "aws_lambda_function" "sqs_poll" {
  filename      = "handler_pollSQS.zip"
  function_name = "${var.lambda_function_name_sqs_poll}"
  role          = aws_iam_role.sqs_poll_lambda_role.arn
  handler       = "handler_pollSQS.lambda_handler"

  source_code_hash = "${data.archive_file.zipit2.output_base64sha256}"

  runtime = "python3.8"
  timeout = 60
  depends_on = [
    aws_iam_role_policy_attachment.sqs_poll_lambda_logs,
    aws_cloudwatch_log_group.sqs_poll_lambda_log_group,
  ]
}

resource "aws_cloudwatch_log_group" "sqs_poll_lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name_sqs_poll}"
  retention_in_days = 14
}


resource "aws_iam_policy" "sqs_poll_lambda_policy" {
  name        = "sqs_poll_lambda_policy"
  path        = "/"
  description = "IAM policy for logging from a sqs_poll lambda function"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
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
        "Effect": "Allow",
        "Action": "dynamodb:*",
        "Resource": "*"
    },
    {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData",
                "ds:CreateComputer",
                "ds:DescribeDirectories",
                "ec2:DescribeInstanceStatus",
                "logs:*",
                "ssm:*",
                "ec2messages:*",
                "sqs:*",
                "dynamo:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "arn:aws:iam::*:role/aws-service-role/ssm.amazonaws.com/AWSServiceRoleForAmazonSSM*",
            "Condition": {
                "StringLike": {
                    "iam:AWSServiceName": "ssm.amazonaws.com"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:DeleteServiceLinkedRole",
                "iam:GetServiceLinkedRoleDeletionStatus"
            ],
            "Resource": "arn:aws:iam::*:role/aws-service-role/ssm.amazonaws.com/AWSServiceRoleForAmazonSSM*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel"
            ],
            "Resource": "*"
        }
  ]
}
EOF
}

resource "aws_iam_role" "sqs_poll_lambda_role" {
  name = "sqs_poll_lambda_role"
  assume_role_policy = <<EOF
{
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
}
EOF
}

resource "aws_iam_role_policy_attachment" "sqs_poll_lambda_logs" {
  role       = aws_iam_role.sqs_poll_lambda_role.name
  policy_arn = aws_iam_policy.sqs_poll_lambda_policy.arn
}