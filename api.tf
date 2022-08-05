module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name          = "blogger-http"
  description   = "My awesome HTTP API Gateway"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  
  # Routes and integrations
  integrations = {
    "GET /all_comments" = {
      lambda_arn             =  "${aws_lambda_function.get_comments.arn}"
      payload_format_version = "2.0"
    }

    "POST /comment" = {
      lambda_arn             = "${aws_lambda_function.put_sqs.arn}"
      payload_format_version = "2.0"
    }


  }
  create_api_domain_name           = false  # to control creation of API Gateway Domain Name


  tags = {
    Name = "http-apigateway"
  }
  depends_on = [
    aws_lambda_function.get_comments,
    aws_lambda_function.put_sqs
  ]
}

