# API Gateway lambda Integration
resource "aws_api_gateway_rest_api" "demo_tool_apigw" {
  name = "demo_tool_automation"
  description = "API Gateway for Tools Automation"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags               = {
    AssetID       = "2516",
    AssetName     = "SRE Tooling",
    AssetArea     = "sre-tools"
    ControlledBy  = "terraform"
  }
}

# Automation Tool Gateway - Brown Bag Demo
resource "aws_api_gateway_resource" "demo_tool_apigw_resource" {
  rest_api_id = aws_api_gateway_rest_api.demo_tool_apigw.id
  parent_id   = aws_api_gateway_rest_api.demo_tool_apigw.root_resource_id
  path_part   = "demo_tools"
  depends_on = [aws_api_gateway_rest_api.demo_tool_apigw]
}

resource "aws_api_gateway_method" "demo_tool_apigw_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.demo_tool_apigw.id
  resource_id   = aws_api_gateway_resource.demo_tool_apigw_resource.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.demo_tool_apigw_authorizer.id

  request_parameters = {
     "method.request.header.Authorization" = true
  }

  depends_on = [aws_api_gateway_rest_api.demo_tool_apigw,aws_api_gateway_resource.demo_tool_apigw_resource]
}


resource "aws_api_gateway_integration" "demo_tool_apigw_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.demo_tool_apigw.id
  resource_id = aws_api_gateway_resource.demo_tool_apigw_resource.id
  http_method = aws_api_gateway_method.demo_tool_apigw_post_method.http_method
  integration_http_method = "POST"
  type        = "AWS"
  uri         = aws_lambda_function.demo_post_tool_lambda_function.invoke_arn

  passthrough_behavior = "WHEN_NO_TEMPLATES"

  request_templates = {
  "application/json" = <<EOF
  ##  See http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-mapping-template-reference.html
  ##  This template will pass through all parameters including path, querystring, header, stage variables, and context through to the integration endpoint via the body/payload
  #set($allParams = $input.params())
  {
  "body-json" : $input.json('$'),
  "params" : {
  #foreach($type in $allParams.keySet())
      #set($params = $allParams.get($type))
  "$type" : {
      #foreach($paramName in $params.keySet())
      "$paramName" : "$util.escapeJavaScript($params.get($paramName))"
          #if($foreach.hasNext),#end
      #end
  }
      #if($foreach.hasNext),#end
  #end
  },
  "stage-variables" : {
  #foreach($key in $stageVariables.keySet())
  "$key" : "$util.escapeJavaScript($stageVariables.get($key))"
      #if($foreach.hasNext),#end
  #end
  },
  "context" : {
      "account-id" : "$context.identity.accountId",
      "api-id" : "$context.apiId",
      "api-key" : "$context.identity.apiKey",
      "authorizer-principal-id" : "$context.authorizer.principalId",
      "caller" : "$context.identity.caller",
      "cognito-authentication-provider" : "$context.identity.cognitoAuthenticationProvider",
      "cognito-authentication-type" : "$context.identity.cognitoAuthenticationType",
      "cognito-identity-id" : "$context.identity.cognitoIdentityId",
      "cognito-identity-pool-id" : "$context.identity.cognitoIdentityPoolId",
      "http-method" : "$context.httpMethod",
      "stage" : "$context.stage",
      "source-ip" : "$context.identity.sourceIp",
      "user" : "$context.identity.user",
      "user-agent" : "$context.identity.userAgent",
      "user-arn" : "$context.identity.userArn",
      "request-id" : "$context.requestId",
      "resource-id" : "$context.resourceId",
      "resource-path" : "$context.resourcePath"
      }
  }
  EOF
  "application/x-www-form-urlencoded" = <<EOF
  ##  See http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-mapping-template-reference.html
  ##  This template will pass through all parameters including path, querystring, header, stage variables, and context through to the integration endpoint via the body/payload
  #set($allParams = $input.params())
  {
  "body-json" : $input.json('$'),
  "params" : {
  #foreach($type in $allParams.keySet())
      #set($params = $allParams.get($type))
  "$type" : {
      #foreach($paramName in $params.keySet())
      "$paramName" : "$util.escapeJavaScript($params.get($paramName))"
          #if($foreach.hasNext),#end
      #end
  }
      #if($foreach.hasNext),#end
  #end
  },
  "stage-variables" : {
  #foreach($key in $stageVariables.keySet())
  "$key" : "$util.escapeJavaScript($stageVariables.get($key))"
      #if($foreach.hasNext),#end
  #end
  },
  "context" : {
      "account-id" : "$context.identity.accountId",
      "api-id" : "$context.apiId",
      "api-key" : "$context.identity.apiKey",
      "authorizer-principal-id" : "$context.authorizer.principalId",
      "caller" : "$context.identity.caller",
      "cognito-authentication-provider" : "$context.identity.cognitoAuthenticationProvider",
      "cognito-authentication-type" : "$context.identity.cognitoAuthenticationType",
      "cognito-identity-id" : "$context.identity.cognitoIdentityId",
      "cognito-identity-pool-id" : "$context.identity.cognitoIdentityPoolId",
      "http-method" : "$context.httpMethod",
      "stage" : "$context.stage",
      "source-ip" : "$context.identity.sourceIp",
      "user" : "$context.identity.user",
      "user-agent" : "$context.identity.userAgent",
      "user-arn" : "$context.identity.userArn",
      "request-id" : "$context.requestId",
      "resource-id" : "$context.resourceId",
      "resource-path" : "$context.resourcePath"
      }
  }
  EOF
  }
}

resource "aws_api_gateway_method_response" "demo_tool_apigw_post_response_200" {
  rest_api_id = aws_api_gateway_rest_api.demo_tool_apigw.id
  resource_id = aws_api_gateway_resource.demo_tool_apigw_resource.id
  http_method = aws_api_gateway_method.demo_tool_apigw_post_method.http_method
  status_code = "200"

  response_parameters = {
     "method.response.header.Content-Type" = true
  }
  response_models = {
         "application/json" = "Empty"
    }
  depends_on = [aws_api_gateway_resource.demo_tool_apigw_resource,
                aws_api_gateway_rest_api.demo_tool_apigw,
                aws_api_gateway_method.demo_tool_apigw_post_method]
}

resource "aws_api_gateway_method_response" "demo_tool_apigw_post_response_403" {
  rest_api_id = aws_api_gateway_rest_api.demo_tool_apigw.id
  resource_id = aws_api_gateway_resource.demo_tool_apigw_resource.id
  http_method = aws_api_gateway_method.demo_tool_apigw_post_method.http_method
  status_code = "403"

  response_parameters = {
     "method.response.header.Content-Type" = true
  }
  response_models = {
            "application/json" = "Empty"
    }
  depends_on = [aws_api_gateway_resource.demo_tool_apigw_resource,
                aws_api_gateway_rest_api.demo_tool_apigw,
                aws_api_gateway_method.demo_tool_apigw_post_method]
}

resource "aws_api_gateway_integration_response" "sre_ops_tool_apigw_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.demo_tool_apigw.id
  resource_id = aws_api_gateway_resource.demo_tool_apigw_resource.id
  http_method = aws_api_gateway_method.demo_tool_apigw_post_method.http_method
  status_code = aws_api_gateway_method_response.demo_tool_apigw_post_response_200.status_code

  response_parameters = {
    "method.response.header.Content-Type" = "'text/xml'"
  }

  response_templates = {
    "application/json" = <<EOF
  $input.path('$')
  EOF
  }

  depends_on = [aws_api_gateway_resource.demo_tool_apigw_resource,
                aws_api_gateway_rest_api.demo_tool_apigw,
                aws_api_gateway_method_response.demo_tool_apigw_post_response_200,
                aws_api_gateway_method.demo_tool_apigw_post_method,
                aws_api_gateway_integration.demo_tool_apigw_post_integration]
}

#resource "aws_api_gateway_method" "demo_tool_apigw_get_method" {
#  rest_api_id   = aws_api_gateway_rest_api.demo_tool_apigw.id
#  resource_id   = aws_api_gateway_resource.demo_tool_apigw_resource.id
#  http_method   = "GET"
#  authorization = "CUSTOM"
#  authorizer_id = aws_api_gateway_authorizer.demo_tool_apigw_authorizer.id
#
#  request_parameters = {
#     "method.request.header.Authorization" = true
#  }
#
#  depends_on = [aws_api_gateway_rest_api.demo_tool_apigw,aws_api_gateway_resource.demo_tool_apigw_resource]
#}

resource "aws_api_gateway_method" "demo_tool_apigw_get_method" {
  rest_api_id   = aws_api_gateway_rest_api.demo_tool_apigw.id
  resource_id   = aws_api_gateway_resource.demo_tool_apigw_resource.id
  http_method   = "GET"
  authorization = "NONE"

  depends_on = [aws_api_gateway_rest_api.demo_tool_apigw,aws_api_gateway_resource.demo_tool_apigw_resource]
}

resource "aws_api_gateway_integration" "demo_tool_apigw_get_integration" {
  rest_api_id = aws_api_gateway_rest_api.demo_tool_apigw.id
  resource_id = aws_api_gateway_resource.demo_tool_apigw_resource.id
  http_method = aws_api_gateway_method.demo_tool_apigw_get_method.http_method
  integration_http_method = "POST"
  type        = "AWS"
  uri         = aws_lambda_function.demo_get_tool_lambda_function.invoke_arn
}

resource "aws_api_gateway_method_response" "demo_tool_apigw_get_response_200" {
  rest_api_id = aws_api_gateway_rest_api.demo_tool_apigw.id
  resource_id = aws_api_gateway_resource.demo_tool_apigw_resource.id
  http_method = aws_api_gateway_method.demo_tool_apigw_get_method.http_method
  status_code = "200"

  response_models = {
         "application/json" = "Empty"
  }

  depends_on = [aws_api_gateway_resource.demo_tool_apigw_resource,
                aws_api_gateway_rest_api.demo_tool_apigw,
                aws_api_gateway_method.demo_tool_apigw_get_method]
}


resource "aws_api_gateway_integration_response" "demo_tool_apigw_get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.demo_tool_apigw.id
  resource_id = aws_api_gateway_resource.demo_tool_apigw_resource.id
  http_method = aws_api_gateway_method.demo_tool_apigw_get_method.http_method
  status_code = aws_api_gateway_method_response.demo_tool_apigw_get_response_200.status_code

  response_templates = {
    "application/json" = <<EOF
  $input.path('$')
  EOF
  }

  depends_on = [aws_api_gateway_resource.demo_tool_apigw_resource,
                aws_api_gateway_rest_api.demo_tool_apigw,
                aws_api_gateway_method_response.demo_tool_apigw_get_response_200,
                aws_api_gateway_method.demo_tool_apigw_get_method,
                aws_api_gateway_integration.demo_tool_apigw_get_integration]
}

// API Gateway Authorizer
resource "aws_api_gateway_authorizer" "demo_tool_apigw_authorizer" {
  name                   = "demo_tool_apigw_authorizer_brownbag_demo"
  rest_api_id            = aws_api_gateway_rest_api.demo_tool_apigw.id
  authorizer_uri         = aws_lambda_function.lambda_demo_tool_authorizer.invoke_arn
  authorizer_credentials = data.aws_iam_role.demo_tool_auth_role.arn
  identity_source        = "method.request.header.Authorization, method.request.header.Referer"
  type                   = "REQUEST"
}

resource "aws_api_gateway_deployment" "demo_tool_apigw_deployment" {
  rest_api_id = aws_api_gateway_rest_api.demo_tool_apigw.id
  stage_name  = "demo_tools_dev"

  depends_on = [aws_api_gateway_integration.demo_tool_apigw_post_integration]
}

output "deployment-url" {
  value = aws_api_gateway_deployment.demo_tool_apigw_deployment.invoke_url
}
