// Demo Tool Lambda Function
resource "aws_lambda_function" "demo_post_tool_lambda_function" {
  filename           = local.demo_post_zip_location
  function_name      = "demo_post_tool_lambda_brownbag_demo"
  handler            = "Brownbag_demo.handler"
  role               = data.aws_iam_role.demo_tool_lambda_role.arn
  runtime            = "python3.8"
  memory_size        = 512
  timeout            = 600

  source_code_hash   = filebase64sha256(local.demo_post_zip_location)
  depends_on         = [data.aws_iam_role.demo_tool_lambda_role]

  tags               = {
    AssetID       = "2516",
    AssetName     = "SRE Tooling",
    AssetArea     = "sre-tools"
    ControlledBy  = "terraform"
  }
}

resource "aws_lambda_function" "demo_get_tool_lambda_function" {
  filename           = local.demo_get_zip_location
  function_name      = "demo_get_tool_lambda_brownbag"
  handler            = "Brownbag_get_demo.handler"
  role               = data.aws_iam_role.demo_tool_lambda_role.arn
  runtime            = "python3.8"
  memory_size        = 512
  timeout            = 600

  source_code_hash   = filebase64sha256(local.demo_get_zip_location)
  depends_on         = [data.aws_iam_role.demo_tool_lambda_role]

  tags               = {
    AssetID       = "2516",
    AssetName     = "SRE Tooling",
    AssetArea     = "sre-tools"
    ControlledBy  = "terraform"
  }
}

// api gateway authorizer Lambda Function
resource "aws_lambda_function" "lambda_demo_tool_authorizer" {
  filename          = local.apigw_authorizer_zip_location
  function_name     = "demo_tool_lambda_authorizer"
  role              = data.aws_iam_role.demo_tool_lambda_role.arn
  handler           = "lambda_authorizer.auth_handler"
  runtime           = "python3.8"
  memory_size        = 512
  timeout            = 300

  source_code_hash  = filebase64sha256(local.apigw_authorizer_zip_location)
  depends_on        = [data.aws_iam_role.demo_tool_lambda_role]

  tags               = {
    AssetID       = "2516",
    AssetName     = "SRE Tooling",
    AssetArea     = "sre-tools"
    ControlledBy  = "terraform"
  }
}
