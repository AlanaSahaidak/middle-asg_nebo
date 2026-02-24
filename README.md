# AWS Autoscaling Group (ASG) Implementation

This project implements an automated scaling solution for EC2 instances in AWS, demonstrating VM autoscaling based on CPU utilization and scheduled actions. 

## Overview
The setup creates a VPC, launch template, autoscaling group, dynamic scaling policies (CPU-based), scheduled scaling actions (business hours), and CloudWatch logging/notifications.

## Architecture
- **VPC**: Secure network with subnet, IGW, routes, and security group (allows SSH/HTTP).
- **Launch Template**: Uses Amazon Linux 2 AMI on t3.micro instances.
- **Autoscaling Group**: Min 1, Max 3 instances, EC2 health checks.
- **Dynamic Policies**: Scale-out (>70% CPU), scale-in (<30% CPU) with 300s cooldown.
- **Scheduled Actions**: Scale to 2 instances at 8 AM Mon-Fri; 1 at 6 PM Mon-Fri.
- **Monitoring**: CloudWatch metrics, logs, and SNS email notifications.

## Scaling Strategy
- **Reactive (Dynamic)**: Automatically adjusts instance count based on real CPU metrics to handle workload spikes.
- **Proactive (Scheduled)**: Scales for predictable patterns (e.g., business hours).
- **Health & Cooldown**: Ensures only healthy instances; prevents excessive scaling with cooldowns.
- **Cost Optimization**: Uses free-tier instances; scales in when idle.

## Metric Thresholds
- **Scale-Out**: CPU >70% (average over 4 minutes, 2 evaluation periods).
- **Scale-In**: CPU <30% (average over 4 minutes).
- **Cooldown**: 300 seconds between scaling actions.
- **Health Check**: 300 seconds grace period for EC2 health.

## Policy Types
- **Dynamic Policies**: Respond to metrics (CPU). Use "ChangeInCapacity" for simple adjustments. Difference from scheduled: Reactive vs. time-based.
- **Scheduled Policies**: Time-based (cron-like). Difference: Proactive, overrides dynamic if conflicting.
- **Simple vs. Step Scaling**: This uses simple (fixed adjustment); step would use percentage-based rules for more granular control.

## Deployment Steps
1. Install Terraform and AWS CLI.
2. Configure AWS: `aws configure` (region: eu-central-1).
3. Clone this repo.
4. Run: `terraform init`, `terraform plan`, `terraform apply`.
5. Verify in AWS Console: VPC, ASG, policies created.

## Testing Instructions
1. Deploy the stack.
2. SSH into instance: `ssh ec2-user@<public-ip>`.
3. Install stress: `sudo yum install stress -y`.
4. Scale-Out: Run `stress --cpu 1 --timeout 600` (CPU >70%, triggers add instance).
5. Scale-In: Stop stress (CPU <30%, triggers remove instance).
6. Scheduled: Wait for 8 AM/6 PM for auto-scaling.
7. Monitor: AWS Console (CloudWatch graphs, ASG activity, logs/emails).

## Monitoring
- **Graphs**: CloudWatch dashboard shows CPU and instance count.
- **Events**: Logs in "/aws/autoscaling/asg-demo"; emails for launches/terminates.
- **Console**: EC2 > Auto Scaling Groups; CloudWatch > Metrics/Alarms.

## CloudWatch Dashboard
A CloudWatch dashboard `ASG-Monitoring` is included via Terraform (`monitoring.tf`). It contains widgets for:

- **CPU Utilization**: `AWS/EC2` CPUUtilization for the Auto Scaling Group (shows spikes that trigger scale-out).
- **Instance Count**: `AWS/AutoScaling` GroupTotalInstances for the Auto Scaling Group (shows scale-out/in events).
