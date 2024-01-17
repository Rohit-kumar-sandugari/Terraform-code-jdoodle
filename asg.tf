
resource "aws_launch_configuration" "as_conf" {
  name_prefix   = "autoscaling-example-"
  image_id      = "ami-0b0ea68c435eb488d" # Replace with the correct Ubuntu AMI
  instance_type = "t2.micro"   # Replace with the desired instance type
  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_instance_profile.name
  user_data = <<-EOF
              #!/bin/bash
              # Install CloudWatch Agent
              wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
              dpkg -i -E ./amazon-cloudwatch-agent.deb
              # Create the CloudWatch Agent configuration file
          cat <<'CONFIG' > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
          {
            "agent": {
              "metrics_collection_interval": 60,
              "run_as_user": "cwagent"
            },
            "metrics": {
              "append_dimensions": {
                "AutoScalingGroupName": "$${aws:AutoScalingGroupName}"
              },
              "metrics_collected": {
                "load": {
                  "measurement": [
                    "load1", "load5", "load15"
                  ],
                  "metrics_collection_interval": 60
                }
              }
            }
          }
          CONFIG

          # Start the CloudWatch Agent
          systemctl enable amazon-cloudwatch-agent
          systemctl start amazon-cloudwatch-agent
          EOF
lifecycle {
create_before_destroy = true
}
}

resource "aws_autoscaling_group" "as_group" {
  launch_configuration = aws_launch_configuration.as_conf.id
vpc_zone_identifier  = data.aws_subnets.default.ids

  min_size = var.min_size
  max_size = var.max_size

  tag {
    key                 = "Name"
    value               = "my-autoscaling-group-instance"
    propagate_at_launch = true
  }

  // Define health check type and grace period if necessary
  // health_check_type           = "EC2"
  // health_check_grace_period   = 300
}

resource "aws_autoscaling_notification" "notifications" {
group_names = [
aws_autoscaling_group.as_group.name,
]
notifications = [
"autoscaling:EC2_INSTANCE_LAUNCH",
"autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
"autoscaling:EC2_INSTANCE_TERMINATE",
"autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
]
topic_arn = aws_sns_topic.autoscaling_notifications.arn
}

// Define scheduled actions for instance replacement
resource "aws_autoscaling_schedule" "replace_instances" {
scheduled_action_name = "replace-instances"
min_size = var.min_size
max_size = var.max_size
desired_capacity = var.min_size // Set to your desired capacity
start_time = "2024-01-20T00:00:00Z" // UTC time
recurrence = "0 0 * * *" // Every day at midnight
autoscaling_group_name = aws_autoscaling_group.as_group.name
}
