resource "aws_dynamodb_table" "comments" {
    name = "comments"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "id"

    attribute {
      name = "id"
      type = "N"
    }
  
}