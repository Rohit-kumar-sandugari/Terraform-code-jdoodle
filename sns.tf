
// Define SNS topics and notifications
resource "aws_sns_topic" "autoscaling_notifications" {
name = "autoscaling-notifications"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.autoscaling_notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email  
}


