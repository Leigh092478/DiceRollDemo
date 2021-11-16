terraform {
  backend "s3" {
    region         = "us-east-2"
    bucket         = "sreops-automation-dev"
    key            = "sreops_tool/product-dev/global/automation-brownbag_demo/terraform_state"
    dynamodb_table = "product-dev-tf-state-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
}

locals {
  demo_post_zip_location = "../../../lambda/brownbag_demo/outputs/brownbag_demo.zip"
  demo_get_zip_location = "../../../lambda/brownbag_get_demo/outputs/brownbag_get_demo.zip"
  apigw_authorizer_zip_location = "../../../lambda/gateway_authorizer/outputs/apigw_authorizer.zip"
}

// IAM Roles
data "aws_iam_role" "demo_tool_lambda_role" {
  name = "sre_ops_tool_automation_lambda_exec_role"
}

data "aws_iam_role" "demo_tool_auth_role" {
  name = "sre_ops_tool_automation_auth_invocation"
}

// Archiving the files
data "archive_file" "brownbag_post_demo" {
  type          = "zip"
  source_dir    = "../../../lambda/brownbag_demo"
  output_path   = local.demo_post_zip_location
}

data "archive_file" "brownbag_get_demo" {
  type          = "zip"
  source_dir    = "../../../lambda/brownbag_get_demo"
  output_path   = local.demo_get_zip_location
}

data "archive_file" "apigw_authorizer" {
  type          = "zip"
  source_dir    = "../../../lambda/gateway_authorizer"
  output_path   = local.apigw_authorizer_zip_location
}
