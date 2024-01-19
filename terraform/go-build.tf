locals {
  go_src            = "go-lambda"
  go_src_dir        = abspath("${path.module}/../${local.go_src}")
  go_lambda_zip     = "lambda.zip"
  go_lambda_zip_dir = abspath("${local.go_src_dir}/${local.go_lambda_zip}")
  go_bin            = "bin"
}

resource "docker_container" "go_build_container" {
  name        = "go-builder"
  image       = "golang:1.19"
  working_dir = local.container_dir
  command     = ["go", "build", "-o", "${local.go_bin}/main"]
  attach      = true
  must_run    = false
  env         = ["GOARCH=amd64", "GOOS=linux"]
  volumes {
    host_path      = local.go_src_dir
    container_path = local.container_dir
  }
}

data "archive_file" "go_lambda_zip" {
  depends_on  = [docker_container.go_build_container]
  type        = "zip"
  source_dir  = "${local.go_src_dir}/${local.go_bin}"
  output_path = local.go_lambda_zip_dir
}
