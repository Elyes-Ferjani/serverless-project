data "archive_file" "zipit3" {
  type        = "zip"
  source_file = "handler_putSQS.py"
  output_path = "handler_putSQS.zip"
}


resource "aws_lambda_function" "put_sqs" {
  filename      = "handler_putSQS.zip"
  function_name = "${var.lambda_function_name_sqs}"
  role          = aws_iam_role.put_sqs_lambda_role.arn
  handler       = "handler_putSQS.lambda_handler"

  source_code_hash = "${data.archive_file.zipit3.output_base64sha256}"

  runtime = "python3.8"
  timeout = 60
  depends_on = [
    aws_iam_role_policy_attachment.put_sqs_lambda_logs,
    aws_cloudwatch_log_group.put_sqs_lambda_log_group,
  ]
}

resource "aws_cloudwatch_log_group" "put_sqs_lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name_sqs}"
  retention_in_days = 14
}


resource "aws_iam_policy" "put_sqs_lambda_policy" {
  name        = "put_sqs_lambda_policy"
  path        = "/"
  description = "IAM policy for logging from a put_sqs lambda function"

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
                "sqs:*"
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

resource "aws_iam_role" "put_sqs_lambda_role" {
  name = "put_sqs_lambda_role"
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

resource "aws_iam_role_policy_attachment" "put_sqs_lambda_logs" {
  role       = aws_iam_role.put_sqs_lambda_role.name
  policy_arn = aws_iam_policy.put_sqs_lambda_policy.arn
}