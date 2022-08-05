resource "aws_s3_bucket" "blog_bucket" {
  bucket = "blog-website-project.aws"
  acl    = "public-read"
  policy = file("policy.json")

  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket_object" "upload_html" {

  bucket = "${aws_s3_bucket.blog_bucket.id}"

  key    = "index.html"

  acl    = "public-read" 

  source = "assets/index.html"

  etag = filemd5("assets/index.html")

}

resource "local_file" "js_file" {
  content = templatefile("index.tmpl",
  {
   api_dns = module.api_gateway.apigatewayv2_api_api_endpoint
  }
  )
  filename = "${path.module}/assets/index.js"
}

resource "aws_s3_bucket_object" "upload_js" {

  bucket = "${aws_s3_bucket.blog_bucket.id}"

  key    = "index.js"

  acl    = "public-read" 

  source = "${template_file.js_file.rendered}"

  
  depends_on = [
    local_file.js_file
  ]

}

resource "template_file" "js_file" {
  template = "${path.module}/index.tmpl"
  vars = { 
   api_dns = module.api_gateway.apigatewayv2_api_api_endpoint
  }
}

