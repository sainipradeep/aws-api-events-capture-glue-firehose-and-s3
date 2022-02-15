resource "aws_api_gateway_rest_api" "api-gateway" {
  name        = "api-gateway-SQS"
  description = "POST records to SQS queue"
}

resource "aws_api_gateway_resource" "login" {
    rest_api_id = aws_api_gateway_rest_api.apiGateway.id
    parent_id   = aws_api_gateway_rest_api.apiGateway.root_resource_id
    path_part   = "login"
}

resource "aws_api_gateway_request_validator" "validator_query" {
  name                        = "queryValidator"
  rest_api_id                 = aws_api_gateway_rest_api.apiGateway.id
  validate_request_body       = false
  validate_request_parameters = true
}

resource "aws_api_gateway_method" "method_login" {
    rest_api_id   = aws_api_gateway_rest_api.apiGateway.id
    resource_id   = aws_api_gateway_resource.login.id
    http_method   = "POST"
    authorization = "NONE"

    request_parameters = {
      "method.request.path.proxy"        = false
      "method.request.querystring.unity" = false
  }

  request_validator_id = aws_api_gateway_request_validator.validator_query.id
}

resource "aws_api_gateway_integration" "api" {
  rest_api_id             = aws_api_gateway_rest_api.apiGateway.id
  resource_id             = aws_api_gateway_resource.login.id
  http_method             = aws_api_gateway_method.method_login.http_method
  type                    = "AWS"
  integration_http_method = "POST"
  credentials             = var.api_sqs_arn
  uri                     = "arn:aws:apigateway:${var.region}:sqs:path/${var.main_queue_arn_name}"

  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }

  # Request Template for passing Method, Body, QueryParameters and PathParams to SQS messages
  request_templates = {
    "application/json" = <<EOF
      Action=SendMessage&MessageBody={
        "method": "$context.httpMethod",
        "body-json" : $input.json('$'),
        "queryParams": {
          #foreach($param in $input.params().querystring.keySet())
          "$param": "$util.escapeJavaScript($input.params().querystring.get($param))" #if($foreach.hasNext),#end
        #end
        },
        "pathParams": {
          #foreach($param in $input.params().path.keySet())
          "$param": "$util.escapeJavaScript($input.params().path.get($param))" #if($foreach.hasNext),#end
          #end
        }
      }"
  EOF
  }
    # aws_iam_role_policy_attachment.api_exec_role

  depends_on = [
    var.api_exec_role
  ]
}


# Mapping SQS Response
resource "aws_api_gateway_method_response" "http200" {
 rest_api_id = aws_api_gateway_rest_api.apiGateway.id
 resource_id = aws_api_gateway_resource.login.id
 http_method = aws_api_gateway_method.method_login.http_method
 status_code = 200
}

resource "aws_api_gateway_integration_response" "http200" {
 rest_api_id       = aws_api_gateway_rest_api.apiGateway.id
 resource_id       = aws_api_gateway_resource.login.id
 http_method       = aws_api_gateway_method.method_login.http_method
 status_code       = aws_api_gateway_method_response.http200.status_code
 selection_pattern = "^2[0-9][0-9]"                                       // regex pattern for any 200 message that comes back from SQS

 depends_on = [
   aws_api_gateway_integration.api
   ]
}

resource "aws_api_gateway_deployment" "api" {
 rest_api_id = aws_api_gateway_rest_api.apiGateway.id
 stage_name  = var.environment

 depends_on = [
   aws_api_gateway_integration.api,
 ]

 # Redeploy when there are new updates
 triggers = {
   redeployment = sha1(
     jsonencode(aws_api_gateway_integration.api.id),
   )
 }

 lifecycle {
   create_before_destroy = true
 }
}