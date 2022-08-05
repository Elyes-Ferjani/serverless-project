resource "aws_sqs_queue" "messages_queue" {
    name = "comments"
    visibility_timeout_seconds = 60
}