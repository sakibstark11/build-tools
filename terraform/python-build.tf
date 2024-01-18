locals {
  python_src            = "python-lambda"
  python_src_dir        = abspath("${path.module}/../${local.python_src}")
  python_dependencies   = "package"
  python_lambda_zip     = "python-lambda.zip"
  python_lambda_zip_dir = abspath("${local.python_src_dir}/${local.python_lambda_zip}")
}

resource "docker_container" "python_build_container" {
  name        = "python-builder"
  image       = "python:3.12.1-slim"
  working_dir = local.container_dir
  command     = ["pip", "install", "-r", "requirements.txt", "-t", "${local.python_dependencies}"]
  attach      = true
  must_run    = false
  volumes {
    host_path      = local.python_src_dir
    container_path = local.container_dir
  }
}

data "archive_file" "python_lambda_zip" {
  depends_on  = [docker_container.python_build_container]
  type        = "zip"
  source_dir  = local.python_src_dir
  output_path = local.python_lambda_zip_dir
  excludes    = concat(["*__pycache__*", "*.pyc", "*test*", local.python_lambda_zip], tolist(fileset(local.python_src_dir, "${local.python_src}/**")))
}
