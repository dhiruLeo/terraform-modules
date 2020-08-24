provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}


resource "aws_instance" "example" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"
  tags {
        Name = "dhiru"
        KeyName = "terraform"
    }
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "dedicated"

  tags {
    Name = "dhiru-vpc"
  }
}
resource "aws_subnet" "main" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.1.0/24"

  tags {
    Name = "dhiru-pub-sub-a"
    
  }
}
resource "aws_subnet" "main-b" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.2.0/24"

  tags {
    Name = "dhiru-pub-sub-b"
  }
}
resource "aws_subnet" "main-c" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.0.0/24"

  tags {
    Name = "dhiru-priv-db"
  }
}
resource "aws_subnet" "main-d" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.3.0/24"

  tags {
    Name = "dhiru-priv-web"
  }
}
resource "aws_db_instance" "default" {
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "dhiru-db"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql5.7"
}

resource "aws_launch_configuration" "sample_lc" {
  image_id = "ami-009d6802948d06e52"
  instance_type = "t2.micro"
}
resource "aws_autoscaling_group" "sample_asg" {
    vpc_zone_identifier = ["subnet-15d7032b","subnet-243e442b"]
    launch_configuration = "${aws_launch_configuration.sample_lc.name}"
    max_size = 3
    min_size = 1
}
resource "aws_autoscaling_policy" "scale_out_scaling_app" {
    name = "scale-out-cpu-high"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = "${aws_autoscaling_group.sample_asg.name}"
}
resource "aws_autoscaling_policy" "scale_in_scaling_app" {
    name = "scale-in-cpu-normal"
    scaling_adjustment = -1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = "${aws_autoscaling_group.sample_asg.name}"
}
resource "aws_cloudwatch_metric_alarm" "scaling_app_high" {
    alarm_name = "sample-cpu-utilization-exceeds-normal"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "1"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "60"
    statistic = "Average"
    threshold = "75"
    alarm_description = "This metric monitors ec2  CPU for high utilization on hosts"
    dimensions {
        AutoScalingGroupName = "${aws_autoscaling_group.sample_asg.name}"
    }
    alarm_actions = ["${aws_autoscaling_policy.scale_out_scaling_app.arn}"]
}
resource "aws_cloudwatch_metric_alarm" "scaling_app_low" {
    alarm_name = "sample-cpu-utilization-normal"
    comparison_operator = "LessThanThreshold"
    evaluation_periods = "1"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "60"
    statistic = "Average"
    threshold = "60"
    alarm_description = "This metric monitors ec2  CPU for low utilization on hosts"
    dimensions {
        AutoScalingGroupName = "${aws_autoscaling_group.sample_asg.name}"
    }
    alarm_actions = ["${aws_autoscaling_policy.scale_in_scaling_app.arn}"]
    #Memory Utilization
}
resource "aws_cloudwatch_metric_alarm" "memory-high" {
    alarm_name = "mem-util-high-agents"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "MemoryUtilization"
    namespace = "AWS/EC2"
    period = "300"
    statistic = "Average"
    threshold = "80"
    alarm_description = "This metric monitors ec2 memory for high utilization on hosts"
    # alarm_actions   = [ "${aws_sns_topic.alarm.arn}" ]
    dimensions {
        AutoScalingGroupName = "${aws_autoscaling_group.sample_asg.name}"
    }
}
resource "aws_cloudwatch_metric_alarm" "memory-low" {
    alarm_name = "mem-util-low-agents"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "MemoryUtilization"
    namespace = "AWS/EC2"
    period = "300"
    statistic = "Average"
    threshold = "40"
    alarm_description = "This metric monitors ec2 memory for low utilization on  hosts"
    # alarm_actions   = [ "${aws_sns_topic.alarm.arn}" ]
    dimensions {
        AutoScalingGroupName ="${aws_autoscaling_group.sample_asg.name}"
    }
}


#SNS Alarm
resource "aws_sns_topic" "alarm" {
  name = "alarms-topic"
}
resource "aws_sqs_queue" "alarm_queue" {
  name = "alarm-topic-queue"
}

resource "aws_sns_topic_subscription" "alarm_sub" {
  topic_arn = "${aws_sns_topic.alarm.arn}"
  protocol  = "sqs"
  endpoint  = "${aws_sqs_queue.alarm_queue.arn}"
}


module for rds
provider "aws" {
 access_key = "${var.access_key}"
 secret_key = "${var.secret_key}"
 region     = "${var.region}"
}

resource "aws_db_instance" "default" {
 allocated_storage    = 10
 storage_type         = "gp2"
 engine               = "mysql"
 engine_version       = "5.7"
 instance_class       = "db.t2.micro"
 identifier_prefix    = "rds-server-example"
 name                 = "mydb"
 username             = "foo"
 password             = "foobarbaz"
 parameter_group_name = "default.mysql5.7"
 apply_immediately    = "true"
 skip_final_snapshot  = "true"
}

resource "aws_cloudwatch_metric_alarm" "database_cpu_alert" {
 alarm_name          = "${aws_db_instance.default.identifier}-database-cpu-alert"
 evaluation_periods  = "1"
 comparison_operator = "GreaterThanOrEqualToThreshold"
 metric_name         = "CPUUtilization"
 namespace           = "AWS/RDS"
 period              = "300"
 statistic           = "Average"
 threshold           = "80"
 alarm_description   = "Alert generated if the DB is using more than 80% CPU"
#   alarm_actions       = ["arn:aws:sns:eu-west-1:${data.aws_caller_identity.current.account_id}:${var.env}-slack-alert"]

 dimensions {
   "DBInstanceIdentifier" = "${aws_db_instance.default.identifier}"
 }
}
