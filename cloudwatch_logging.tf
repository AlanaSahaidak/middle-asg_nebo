resource "aws_cloudwatch_log_group" "asg_logs" {
  name              = "/aws/autoscaling/asg_nebo"
  retention_in_days = 7

  tags = {
    Environment = "nebo"
    Application = "nebo_asg"
  }
}

resource "aws_cloudwatch_log_stream" "asg_stream" {
  name           = "asg_events"
  log_group_name = aws_cloudwatch_log_group.asg_logs.name
}

resource "aws_autoscaling_notification" "asg_notify" {
  group_names = [aws_autoscaling_group.asg.name]
  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"
  ]
  topic_arn = aws_sns_topic.asg_events.arn
}

resource "aws_sns_topic" "asg_events" {
  name = "asg-events"
}

resource "aws_sns_topic_subscription" "asg_events_email" {
  topic_arn = aws_sns_topic.asg_events.arn
  protocol  = "email"
  endpoint  = "sahaidakalana@gmail.com"
}
