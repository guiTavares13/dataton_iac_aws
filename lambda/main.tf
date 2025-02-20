provider "aws" {
  access_key = "test"
  secret_key = "test"
  region     = "sa-east-1"

  endpoints {
    lambda = "http://127.0.0.1:4566"
  }

  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

data "archive_file" "lambda_package" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "hello_world_lambda" {
  function_name = "hello-world-lambda"
  role          = "arn:aws:iam::000000000000:role/fake-role"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  filename = data.archive_file.lambda_package.output_path

  environment {
    variables = {
      ENV = "local"
    }
  }
}

output "lambda_function_name" {
  value = aws_lambda_function.hello_world_lambda.function_name
}
