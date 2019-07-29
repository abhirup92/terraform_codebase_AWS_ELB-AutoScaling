provider "aws" {
region = "us-east-2"
}

#aws_launch config for ec2 for autoscaling group
resource "aws_launch_configuration" "webcluster" {
name = "ruby_AWS_LC"
image_id= "ami-0c209b87f96c6444f"
instance_type = "t2.micro"
security_groups = "sg-08732d86997bc8fcd"
key_name = "abhi"
user_data = <<-EOF
#!/bin/bash
sudo su root
docker start a08051019de3
EOF

lifecycle {
create_before_destroy = true
}
}

#data "aws_availability_zones" "allzones" {}

resource "aws_autoscaling_group" "aws_autoscaling_group" {
name = "g2_autoscale"
launch_configuration = "${aws_launch_configuration.webcluster.name}"
availability_zones = "us-east-2"
min_size = 1
max_size = 3
#vpc_zone_identifier = ["subnet-01872c4d", "subnet-09a9a361", "subnet-1615566c"]
enabled_metrics = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupTotalInstances"]
metrics_granularity="1Minute"
load_balancers= ["${aws_elb.elb1.id}"]
health_check_type = "ELB"
health_check_grace_period_seconds = "120"
tag {
key = "Name"
value = "terraform-asg-example"
propagate_at_launch = true
}
}
resource "aws_autoscaling_policy" "autopolicy" {
name = "terraform-autoplicy"
scaling_adjustment = 1
adjustment_type = "ChangeInCapacity"
cooldown = 300
autoscaling_group_name = "${aws_autoscaling_group.scalegroup.name}"
}

resource "aws_cloudwatch_metric_alarm" "cpualarm" {
alarm_name = "terraform-alarm"
comparison_operator = "GreaterThanOrEqualToThreshold"
evaluation_periods = "2"
metric_name = "CPUUtilization"
namespace = "AWS/EC2"
period = "120"
statistic = "Average"
threshold = "60"

dimensions {
AutoScalingGroupName = "${aws_autoscaling_group.scalegroup.name}"
}

alarm_description = "This metric monitor EC2 instance cpu utilization"
alarm_actions = ["${aws_autoscaling_policy.autopolicy.arn}"]
}

#
resource "aws_autoscaling_policy" "autopolicy-down" {
name = "terraform-autoplicy-down"
scaling_adjustment = -1
adjustment_type = "ChangeInCapacity"
cooldown = 300
autoscaling_group_name = "${aws_autoscaling_group.scalegroup.name}"
}

resource "aws_cloudwatch_metric_alarm" "cpualarm-down" {
alarm_name = "terraform-alarm-down"
comparison_operator = "LessThanOrEqualToThreshold"
evaluation_periods = "2"
metric_name = "CPUUtilization"
namespace = "AWS/EC2"
period = "120"
statistic = "Average"
threshold = "10"

dimensions {
AutoScalingGroupName = "${aws_autoscaling_group.scalegroup.name}"
}

alarm_description = "This metric monitor EC2 instance cpu utilization"
alarm_actions = ["${aws_autoscaling_policy.autopolicy-down.arn}"]
}

#resource "aws_security_group" "websg" {
#name = "security_group_for_web_server"
#ingress {
#from_port = 80
#to_port = 80
#protocol = "tcp"
#cidr_blocks = ["0.0.0.0/0"]
#}

#lifecycle {
#create_before_destroy = true
#}
#}

#resource "aws_security_group_rule" "ssh" {
#security_group_id = "${aws_security_group.websg.id}"
#type = "ingress"
#from_port = 22
#to_port = 22
#protocol = "tcp"
#cidr_blocks = ["60.242.xxx.xxx/32"]
#}

#resource "aws_security_group" "elbsg" {
#name = "security_group_for_elb"
#ingress {
#from_port = 80
#to_port = 80
#protocol = "tcp"
#cidr_blocks = ["0.0.0.0/0"]
#}

#egress {
#from_port = 0
#to_port = 0
#protocol = "-1"
#cidr_blocks = ["0.0.0.0/0"]
#}

#lifecycle {
#create_before_destroy = true
#}


resource "aws_elb" "elb1" {
name = "terraform-elb"
availability_zones = ["us-east-2"]
security_groups = ["sg-08732d86997bc8fcd"]
access_logs {
bucket = "elb-log.davidwzhang.com"
bucket_prefix = "elb"
interval = 5
}
listener {
instance_port = 3000
instance_protocol = "tcp"
lb_port = 3000
lb_protocol = "tcp"
}
health_check {
healthy_threshold = 2
unhealthy_threshold = 2
timeout = 10
target = "TCP:3000"
interval = 30
}

#cross_zone_load_balancing = true
idle_timeout = 60
connection_draining = true
connection_draining_timeout = 120

tags {
Name = "terraform-elb"
}
}

#resource "aws_lb_cookie_stickiness_policy" "cookie_stickness" {
#name = "cookiestickness"
#load_balancer = "${aws_elb.elb1.id}"
#lb_port = 80
#cookie_expiration_period = 600
#}

output "elb-dns" {
value = "${aws_elb.elb1.dns_name}"
}