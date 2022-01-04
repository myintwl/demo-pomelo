resource "aws_sqs_queue" "queue1" {
  name                      = "apigateway-queue1"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlqueue.arn,
    maxReceiveCount     = 3
  })
  tags = {
    Product = local.app_name
  }
}

resource "aws_sqs_queue" "dlqueue" {
  name                      = "dead letter queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10

  tags = {
    Product = local.app_name
  }
}


# Trigger lambda on message to SQS
resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  batch_size       = 1
  event_source_arn = aws_sqs_queue.queue1.arn
  enabled          = true
  function_name    = aws_lambda_function.lambda_sqs.arn
}

resource "aws_cloudwatch_metric_alarm" "deadletter_alarm" {
  alarm_name          = "${aws_sqs_queue.dlqueue.name}-not-empty-alarm"
  alarm_description   = "Items are on the ${aws_sqs_queue.dlqueue.name} queue"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Average"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alarm.arn]
  dimensions = {
    "QueueName" = aws_sqs_queue.dlqueue.name
  }

  tags = {
    Product = local.app_name
  }
}

resource "aws_sns_topic" "alarm" {
  name = "${local.app_name}-alarm-topic"
}