# Lambda Function for Demo Tool
resource "aws_lambda_permission" "demo_tool_post_apigw_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.demo_post_tool_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.demo_tool_apigw.execution_arn}/*/*/*"
  depends_on = [aws_lambda_function.demo_post_tool_lambda_function,aws_api_gateway_rest_api.demo_tool_apigw]
}

resource "aws_lambda_permission" "demo_tool_get_apigw_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.demo_get_tool_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.demo_tool_apigw.execution_arn}/*/*/*"
  depends_on = [aws_lambda_function.demo_get_tool_lambda_function,aws_api_gateway_rest_api.demo_tool_apigw]
}