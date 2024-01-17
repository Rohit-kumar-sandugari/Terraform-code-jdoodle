
resource "aws_cloudwatch_metric_alarm" "high_load" {
  alarm_name          = "high-load-average"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "LoadAverage" // Your custom metric name
  namespace           = "MyNamespace" // Your custom namespace
  period              = "120"
  statistic           = "Average"
  threshold           = "0.75"
  alarm_description   = "This metric monitors EC2 load average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.as_group.name
  }

  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_up.arn]
  ok_actions      = []
}

resource "aws_cloudwatch_metric_alarm" "low_load" {
  alarm_name          = "low-load-average"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "LoadAverage" // Your custom metric name
  namespace           = "MyNamespace" // Your custom namespace
  period              = "120"
  statistic           = "Average"
  threshold           = "0.50"
  alarm_description   = "This metric monitors EC2 load average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.as_group.name
  }

  actions_enabled = true
 
 alarm_actions = [aws_autoscaling_policy.scale_down.arn]
ok_actions = []
}

// Define scaling policies for autoscaling group
resource "aws_autoscaling_policy" "scale_up" {
name = "scale-up"
scaling_adjustment = 1
adjustment_type = "ChangeInCapacity"
cooldown = 300
autoscaling_group_name = aws_autoscaling_group.as_group.name
}

resource "aws_autoscaling_policy" "scale_down" {
name = "scale-down"
scaling_adjustment = -1
adjustment_type = "ChangeInCapacity"
cooldown = 300
autoscaling_group_name = aws_autoscaling_group.as_group.name
}
