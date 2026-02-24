resource "aws_autoscaling_group" "asg" {
  name                      = "nebo_asg"
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 1
  vpc_zone_identifier       = [aws_subnet.nebo_subnet.id]
  launch_template {
    id      = aws_launch_template.asg_lt.id
    version = "$Latest"
  }
  health_check_type         = "EC2"
  health_check_grace_period = 300
  force_delete              = true

  tag {
    key                 = "Name"
    value               = "ASG_nebo"
    propagate_at_launch = true
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_launch_template" "asg_lt" {
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  key_name      = "nebo-key"

  vpc_security_group_ids = [aws_security_group.nebo_sg.id]

  user_data = base64encode("#!/bin/bash\nyum update -y\nyum install -y httpd\nsystemctl start httpd\nsystemctl enable httpd\nyes > /dev/null &\nyes > /dev/null &\n")

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ASG_Nebo_Instance"
    }
  }
}