terraform {
  backend "s3" {
    region         = "us-east-2"
    bucket         = "demo_tools-automation-dev"
    key            = "demo_tool/product-dev/global/automation-iam/terraform_state"
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