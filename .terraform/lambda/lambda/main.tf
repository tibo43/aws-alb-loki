resource "aws_lambda_function" "function" {
    function_name = "${var.team}-${var.name}"
    role          = var.role
    package_type  = "Image"
    image_uri     = var.image_uri
    source_code_hash    = var.source_code_hash
    timeout       = var.timeout
    memory_size   = var.memory_size
    reserved_concurrent_executions = var.reserved_concurrent_executions
    environment {
        variables = var.variables
    }
    tags = {
        Team          = "${var.team}"
        Product       = "${var.product}"
        Department    = "${var.department}"
        Environment   = "${var.environment}"
    }
}

resource "aws_lambda_function_event_invoke_config" "event_invoke" {
    function_name                = aws_lambda_function.function.function_name
    maximum_event_age_in_seconds = var.maximum_event_age_in_seconds
    maximum_retry_attempts       = var.maximum_retry_attempts
}

resource "aws_cloudwatch_event_rule" "event_rule" {
    name                = "${var.team}-${var.name}"
    schedule_expression = var.schedule
    is_enabled          = var.is_enabled
    tags = {
        Team          = "${var.team}"
        Product       = "${var.product}"
        Department    = "${var.department}"
        Environment   = "${var.environment}"
    }
}

resource "aws_cloudwatch_event_target" "event_target" {
    rule      = aws_cloudwatch_event_rule.event_rule.name
    target_id = "${var.team}-${var.name}"
    arn       = aws_lambda_function.function.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
    statement_id  = "AllowExecutionFromCloudWatch"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.function.function_name
    principal     = "events.amazonaws.com"
    source_arn    = aws_cloudwatch_event_rule.event_rule.arn
}