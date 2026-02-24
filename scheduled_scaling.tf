resource "aws_autoscaling_schedule" "scale_up_business_hours" {
  scheduled_action_name  = "scale-up-business-hours"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  recurrence             = "0 8 * * 1-5" # 8 AM, Monday-Friday
  min_size               = 2
  max_size               = 4
  desired_capacity       = 2
}

resource "aws_autoscaling_schedule" "scale_down_off_hours" {
  scheduled_action_name  = "scale-down-off-hours"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  recurrence             = "0 18 * * 1-5" # 6 PM, Monday-Friday
  min_size               = 1
  max_size               = 4
  desired_capacity       = 1
}
