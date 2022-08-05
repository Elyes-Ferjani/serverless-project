data "archive_file" "zipit1" {
  type        = "zip"
  source_file = "handler_getComments.py"
  output_path = "handler_getComments.zip"
}


resource "aws_lambda_function" "get_comments" {
  filename      = "handler_getComments.zip"
  function_name = "${var.lambda_function_name}"
  role          = aws_iam_role.get_comments_lambda_role.arn
  handler       = "handler_getComments.lambda_handler"

  source_code_hash = "${data.archive_file.zipit1.output_base64sha256}"

  runtime = "python3.8"
  timeout = 60
  depends_on = [
    aws_iam_role_policy_attachment.get_comments_lambda_logs,
    aws_cloudwatch_log_group.get_comments_lambda_log_group,
  ]
}

resource "aws_cloudwatch_log_group" "get_comments_lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}


resource "aws_iam_policy" "get_comments_lambda_policy" {
  name        = "get_comments_lambda_policy"
  path        = "/"
  description = "IAM policy for logging from a get_comments lambda function"

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
                "ec2messages:*"
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

resource "aws_iam_role" "get_comments_lambda_role" {
  name = "get_comments_lambda_role"
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

resource "aws_iam_role_policy_attachment" "get_comments_lambda_logs" {
  role       = aws_iam_role.get_comments_lambda_role.name
  policy_arn = aws_iam_policy.get_comments_lambda_policy.arn
}