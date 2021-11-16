# SRE PEOps Tool Automation
resource "aws_iam_policy" "sre_ops_tool_automation_policy" {
  name = "sre_ops_tool_automation_policy"

  policy = <<-EOF
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "VisualEditor0",
              "Effect": "Allow",
              "Action": [
                  "ssm:SendCommand",
                  "lambda:CreateFunction",
                  "autoscaling:DescribeAutoScalingInstances",
                  "lambda:TagResource",
                  "ec2:DescribeInstances",
                  "ssm:ListCommands",
                  "states:CreateActivity",
                  "ec2:DescribeInstanceAttribute",
                  "ec2:DescribeInstanceStatus",
                  "autoscaling:DescribeLaunchConfigurations",
                  "s3:CreateBucket",
                  "s3:ListBucket",
                  "s3:PutObject",
                  "ses:SendEmail",
                  "logs:CreateLogStream",
                  "autoscaling:DescribeAutoScalingGroups",
                  "states:CreateStateMachine",
                  "states:ListActivities",
                  "lambda:InvokeFunction",
                  "ec2:DescribeTags",
                  "ec2:CreateTags",
                  "logs:CreateLogGroup",
                  "logs:PutLogEvents",
                  "ssm:GetCommandInvocation",
                  "elasticloadbalancing:DescribeTargetHealth",
                  "elasticloadbalancing:DescribeTargetGroups",
                  "elasticloadbalancing:DescribeInstanceHealth",
                  "states:StartExecution",
                  "apigateway:POST"
              ],
              "Resource": "*"
          }
      ]
  }
  EOF
}

resource "aws_iam_role_policy" "sre_ops_tool_automation_auth_invocation_policy" {
  name = "sre_ops_tool_automation_auth_invocation_policy"

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