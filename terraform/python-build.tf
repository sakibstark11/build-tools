locals {
  python_src                  = "python-lambda"
  python_src_dir              = abspath("${path.module}/../${local.python_src}")
  python_lambda_zip           = "lambda.zip"
  python_lambda_zip_dir       = "${local.python_src_dir}/${local.python_lambda_zip}"
  python_lambda_layer         = "layer"
  python_lambda_layer_dir     = "${local.python_src_dir}/${local.python_lambda_layer}"
  python_lambda_layer_zip     = "layer.zip"
  python_lambda_layer_zip_dir = "${local.python_src_dir}/${local.python_lambda_layer_zip}"
  python_requirements_file    = "requirements.txt"
}

resource "docker_container" "python_build_container" {
  name        = "python-builder"
  image       = "python:3.12.1-slim"
  working_dir = local.container_dir
  command     = ["pip", "install", "-r", local.python_requirements_file, "-t", "${local.python_lambda_layer}/python"]
  attach      = true
  must_run    = false
  volumes {
    host_path      = local.python_src_dir
    container_path = local.container_dir
  }
}

data "archive_file" "python_lambda_layer_zip" {
  depends_on  = [docker_container.python_build_container]
  type        = "zip"
  source_dir  = local.python_lambda_layer_dir
  output_path = local.python_lambda_layer_zip_dir
}

data "archive_file" "python_lambda_zip" {
  type        = "zip"
  source_dir  = local.python_src_dir
  output_path = local.python_lambda_zip_dir
  excludes = concat(["*__pycache__*", "*.pyc", "*test*",
    local.python_lambda_zip,
    local.python_lambda_layer_zip],
  tolist(fileset(local.python_src_dir, "${local.python_lambda_layer}/**")))
}

resource "aws_lambda_layer_version" "python_lambda_layer" {
  depends_on          = [data.archive_file.python_lambda_layer_zip]
  filename            = local.python_lambda_layer_zip_dir
  layer_name          = "${local.python_prefix}-layer"
  compatible_runtimes = ["python3.12"]
}
