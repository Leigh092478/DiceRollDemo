# Demo Tool Automation
resource "aws_iam_role" "demo_tool_automation_lambda_execution_role" {
  name = "demo_tool_automation_lambda_exec_role"
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": [
              "lambda.amazonaws.com",
              "states.amazonaws.com"
            ]
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "demo_tool_automation_policy_attachment" {
  role       = aws_iam_role.demo_tool_automation_lambda_execution_role.name
  policy_arn = aws_iam_policy.demo_tool_automation.arn
}

resource "aws_iam_role" "demo_tool_automation_authorizer_invocation_role" {
  name = "demo_tool_automation_auth_invocation"

  assume_role_policy = <<EOF
  {
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "apigateway.amazonaws.com",
          "lambda.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
  EOF
}

resource "aws_iam_role_policy_attachment" "demo_tool_automation_auth_policy_attachment" {
  role       = aws_iam_role.demo_tool_automation_authorizer_invocation_role.name
  policy_arn = aws_iam_policy.demo_tool_automation_auth_invocation_policy.arn
}