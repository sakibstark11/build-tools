locals {
  python_prefix = "python-lambda"
  go_prefix     = "go-lambda"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_iam_role" {
  name               = "${local.python_prefix}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_lambda_function" "python_lambda" {
  filename         = local.python_lambda_zip_dir
  function_name    = "${local.python_prefix}-function"
  role             = aws_iam_role.lambda_iam_role.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.python_lambda_zip.output_base64sha256
  runtime          = "python3.12"
  layers           = [aws_lambda_layer_version.python_lambda_layer.arn]
}

resource "aws_lambda_function" "go_lambda" {
  filename         = local.go_lambda_zip_dir
  function_name    = "${local.go_prefix}-function"
  role             = aws_iam_role.lambda_iam_role.arn
  handler          = "main"
  source_code_hash = data.archive_file.go_lambda_zip.output_base64sha256
  runtime          = "provided.al2"
}
