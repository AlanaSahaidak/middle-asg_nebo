resource "aws_cloudwatch_dashboard" "asg_dashboard" {
  dashboard_name = "ASG_Monitoring"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        x    = 0
        y    = 0
        width  = 12
        height = 6
        properties = {
          metrics    = [["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", aws_autoscaling_group.asg.name]]
          region     = var.region
          title      = "CPU Utilization"
          annotations = {}
        }
      },
      {
        type = "metric"
        x    = 0
        y    = 6
        width  = 12
        height = 6
        properties = {
          metrics    = [["AWS/AutoScaling", "GroupTotalInstances", "AutoScalingGroupName", aws_autoscaling_group.asg.name]]
          region     = var.region
          title      = "Instance Count"
          annotations = {}
        }
      }
    ]
  })
}
