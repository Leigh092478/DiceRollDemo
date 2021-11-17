# Demo Tool Automation
resource "aws_iam_policy" "demo_tool_automation_policy" {
  name = "demo_tool_automation_policy"

  policy = <<-EOF
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "VisualEditor0",
              "Effect": "Allow",
              "Action": [
                  "lambda:CreateFunction",
                  "lambda:TagResource",
                  "s3:CreateBucket",
                  "s3:ListBucket",
                  "logs:CreateLogStream",
                  "lambda:InvokeFunction",
                  "logs:CreateLogGroup",
                  "logs:PutLogEvents",
                  "s3:PutObject",
                  "s3:GetObject",
                  "s3:ListAllMyBuckets",
                  "apigateway:POST"
              ],
              "Resource": "*"
          }
      ]
  }
  EOF
}

resource "aws_iam_role_policy" "demo_tool_automation_auth_invocation_policy" {
  name = "demo_tool_automation_auth_invocation_policy"

  policy = <<EOF
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "VisualEditor0",
              "Effect": "Allow",
              "Action": [
                  "lambda:CreateFunction",
                  "lambda:InvokeFunction",
                  "apigateway:POST"
              ],
              "Resource": "*"
          }
      ]
  }
  EOF
}