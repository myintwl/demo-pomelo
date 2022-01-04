resource "aws_sqs_queue" "queue1" {
  name                      = "apigateway-queue1"
  delay_seconds             = var.delay
  max_message_size          = var.max_size
  message_retention_seconds = var.retention_period
  receive_wait_time_seconds = var.receive_wait
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlqueue.arn,
    maxReceiveCount     = 2
  })
  tags = {
    Product = local.app_name
  }
}

## Create SQS Queue Policy
resource "aws_sqs_queue_policy" "queue1" {
  queue_url = aws_sqs_queue.queue1.id
  policy    = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListQueueTags",
      "sqs:ReceiveMessage",
      "sqs:SendMessage"
      ],
      "Resource": "${aws_sqs_queue.queue1.arn}"
    }
  ]
}
POLICY
}

# Create DLQ 
resource "aws_sqs_queue" "dlqueue" {
  name                      = "dead-letter-queue"
  delay_seconds             = var.delay
  max_message_size          = var.max_size
  message_retention_seconds = var.retention_period
  receive_wait_time_seconds = var.receive_wait

  tags = {
    Product = local.app_name
  }
}

# IAM Policy for DLQ
resource "aws_sqs_queue_policy" "dlq" {
  queue_url = aws_sqs_queue.dlqueue.id
  policy    = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListQueueTags",
      "sqs:ReceiveMessage",
      "sqs:SendMessage"
      ],
      "Resource": "${aws_sqs_queue.dlqueue.arn}"
    }
  ]
}
POLICY
}

# Trigger lambda on message to SQS
resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  batch_size       = 1
  event_source_arn = aws_sqs_queue.queue1.arn
  enabled          = true
  function_name    = aws_lambda_function.lambda_sqs.arn
}

# Cloudwatch Alarm to keep track of DLQ
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

#SNS Topic to record DLQ
resource "aws_sns_topic" "alarm" {
  name = "${local.app_name}-alarm-topic"
}