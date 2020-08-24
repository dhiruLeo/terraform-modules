provider "aws" {
  region                  = "${var.region}"
  shared_credentials_file = "${var.shared_credentials_file}"
  profile                 = "${var.profile}"
  version                 = ">=2.0.0"
}
locals {
  common_tags = {
    environment = "${var.environment}"
    created_by  = "${var.created_by}"
  }
}

resource "aws_vpc" "main" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_hostnames = true
  tags                 = "${merge(map("Name", "${format("%s-%s-vpc", var.name, var.environment)}"), map("kubernetes.io/cluster/${var.name}-${var.environment}", "owned"), "${local.common_tags}")}"

}

data "aws_vpc" "main" {
  tags = "${merge(map("Name", "${format("%s-%s-vpc", var.name, var.environment)}"), map("kubernetes.io/cluster/${var.name}-${var.environment}", "owned"), "${local.common_tags}")}"
}

resource "aws_subnet" "public" {
  vpc_id            = "${var.vpc_id == "" ? data.aws_vpc.main.id : var.vpc_id}"
  cidr_block        = "${element(keys(var.public_subnets), count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  count             = "${length(var.public_subnets)}"
  tags              = "${merge(map("Name", "${format("%s-%s-%s-public-%s", var.name, var.environment, lookup(var.public_subnets, element(keys(var.public_subnets), count.index)), element(split("-", element(var.availability_zones, count.index)), 2))}"), map("subnet-type", "${lookup(var.public_subnets, element(keys(var.public_subnets), count.index))}"), map("az", "${element(var.availability_zones, count.index)}"), map("kubernetes.io/cluster/${var.name}-${var.environment}", "owned"))}"

  lifecycle {
    ignore_changes = ["tags"]
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${var.vpc_id == "" ? data.aws_vpc.main.id : var.vpc_id}"
  #count  = "${length(var.public_subnets) >= 1 ? 1 : 0}" # commented
  tags = "${merge(map("Name", "${format("%s-%s-igw", var.name, var.environment)}"))}"

  lifecycle {
    ignore_changes = ["tags"]
  }

}

resource "aws_route_table" "public" {
  vpc_id = "${var.vpc_id == "" ? data.aws_vpc.main.id : var.vpc_id}"
  count  = "${length(var.availability_zones)}"
  tags   = "${merge(map("Name", "${format("%s-%s-%s-public-rt-%s", var.name, var.environment, lookup(var.public_subnets, element(keys(var.public_subnets), count.index)), element(split("-", element(var.availability_zones, count.index)), 2))}"), map("role", "${lookup(var.public_subnets, element(keys(var.public_subnets), count.index))}"), map("az", "${element(var.availability_zones, count.index)}"))}"
  lifecycle {
    ignore_changes = ["tags"]
  }
}

resource "aws_route" "public" {
  route_table_id         = "${element(aws_route_table.public.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
  count                  = "${length(var.availability_zones)}"
}

resource "aws_route_table_association" "public" {
  count          = "${length(var.public_subnets)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
}

resource "aws_subnet" "private" {
  vpc_id            = "${var.vpc_id == "" ? data.aws_vpc.main.id : var.vpc_id}"
  cidr_block        = "${element(keys(var.private_subnets), count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  count             = "${length(var.private_subnets)}"
  tags              = "${merge(map("Name", "${format("%s-%s-%s-private-%s", var.name, var.environment, lookup(var.private_subnets, element(keys(var.private_subnets), count.index)), element(split("-", element(var.availability_zones, count.index)), 2))}"), map("subnet-type", "${lookup(var.private_subnets, element(keys(var.private_subnets), count.index))}"), map("az", "${element(var.availability_zones, count.index)}"), map("kubernetes.io/cluster/${var.name}-${var.environment}", "owned"))}"
  lifecycle {
    ignore_changes = ["tags"]
  }
}


resource "aws_route_table" "private" {
  vpc_id = "${var.vpc_id == "" ? data.aws_vpc.main.id : var.vpc_id}"
  count  = "${length(var.availability_zones)}"
  tags   = "${merge(map("Name", "${format("%s-%s-%s-rt-private-%s", var.name, var.environment, lookup(var.private_subnets, element(keys(var.private_subnets), count.index)), element(split("-", element(var.availability_zones, count.index)), 2))}"), map("subnet-type", "${lookup(var.private_subnets, element(keys(var.private_subnets), count.index))}"), map("az", "${element(var.availability_zones, count.index)}"))}"
}

resource "aws_route" "private-route" {
  count                  = "${length(var.availability_zones)}"
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
}

resource "aws_route_table_association" "private" {
  count          = "${length(var.private_subnets)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}



resource "aws_eip" "nateip" {
  vpc = true
  #count = 2
  tags = "${merge(map("Name", "${format("%s-%s-%s", var.name, var.environment, element(split("-", var.availability_zones[0]), 2))}"))}"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nateip.id}"
  subnet_id     = "${aws_subnet.public.*.id[0]}"
  tags          = "${merge(map("Name", "${format("%s-%s-%s", var.name, var.environment, element(split("-", var.availability_zones[0]), 2))}"), map("kubernetes.io/cluster/${var.name}-${var.environment}", "owned"))}"
}




resource "aws_iam_role" "kubernetes" {
  name = "kubernetes"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Role policy
resource "aws_iam_role_policy" "kubernetes" {
  name   = "kubernetes"
  role   = "${aws_iam_role.kubernetes.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action" : ["ec2:*"],
      "Effect": "Allow",
      "Resource": ["*"]
    },
    {
      "Action" : ["elasticloadbalancing:*"],
      "Effect": "Allow",
      "Resource": ["*"]
    },
    {
      "Action": "route53:*",
      "Effect": "Allow",
      "Resource": ["*"]
    },
    {
      "Action": "ecr:*",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


# IAM Instance Profile for Controller
resource "aws_iam_instance_profile" "kubernetes" {
  #name = "kubernetes"
  name = "${var.name}-${var.environment}-master-iam-role"
  role = "${aws_iam_role.kubernetes.name}"
}


# # Key pair for the instances

resource "aws_key_pair" "ssh-key" {
  key_name   = "${var.key_name}"
  public_key = "${file("k8s-test.pub")}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "k8s-master" {
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  subnet_id     = "${aws_subnet.public.*.id[0]}"
  #role_arn       = "${aws_iam_role.eks-master-role.arn}"
  iam_instance_profile        = "${aws_iam_instance_profile.kubernetes.name}"
  user_data                   = "${data.template_file.master-userdata.rendered}"
  key_name                    = "${aws_key_pair.ssh-key.key_name}"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${aws_security_group.kubernetes-master.id}"]
  tags                        = "${merge(map("Name", "${format("%s-%s-%s", var.master_name, var.environment, element(split("-", var.availability_zones[0]), 2))}"), map("kubernetes.io/cluster/${var.name}-${var.environment}", "owned"))}"

  depends_on = [
    "aws_iam_role.kubernetes",
  ]
}
resource "aws_security_group" "kubernetes-master" {
  name        = "kubernetes-master"
  description = "Allow inbound ssh traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = "${merge(map("Name", "${format("%s-%s-%s", var.master_name, var.environment, element(split("-", var.availability_zones[0]), 2))}"), map("kubernetes.io/cluster/${var.name}-${var.environment}", "owned"))}"

}


data "template_file" "master-userdata" {
  template = "${file("${var.master-userdata}")}"

  vars = {
    k8stoken = "${var.k8stoken}"
  }
}

# ###############################################
# ## This is eks node IAM roles and policies
# ###############################################

resource "aws_iam_role" "node-role" {
  name = "${var.name}-${var.environment}-node-iam-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "s3_readonly_policy" {
  name = "${var.name}-${var.environment}-node-s3-policy"
  role = "${aws_iam_role.node-role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "ec2_fullaccess_policy" {
  name = "${var.name}-${var.environment}-node-ec2-policy"
  role = "${aws_iam_role.node-role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "ec2:*",
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "elasticloadbalancing:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "cloudwatch:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "autoscaling:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": [
                        "autoscaling.amazonaws.com",
                        "ec2scheduled.amazonaws.com",
                        "elasticloadbalancing.amazonaws.com",
                        "spot.amazonaws.com",
                        "spotfleet.amazonaws.com"
                    ]
                }
            }
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.node-role.name}"
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.node-role.name}"
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.node-role.name}"
}
# The following Roles and Policy are mostly for future use

resource "aws_iam_instance_profile" "node" {
  name = "${var.node_name}-instance-profile"
  role = "${aws_iam_role.node-role.name}"
}

data "template_file" "worker-userdata" {
  template = "${file("${var.worker-userdata}")}"

  vars = {
    k8stoken = "${var.k8stoken}"
    masterIP = "${aws_instance.k8s-master.private_ip}"
  }
}

# data "aws_subnet_ids" "public_subnet_ids" {
#   vpc_id = "${data.aws_vpc.main.id}"
#   tags = {
#     environment = "${var.environment}"
#     subnet-type = "elb"
#   }
#   depends_on = ["aws_subnet.public"]
# }


data "aws_subnet_ids" "node_subnet_ids" {
  vpc_id = "${data.aws_vpc.main.id}"
  tags = {
    environment = "${var.environment}"
    subnet-type = "node"
  }
  depends_on = ["aws_subnet.private"]
}


resource "aws_launch_configuration" "node" {
  name_prefix                 = "worker"
  image_id                    = "${var.ami}"
  instance_type               = "${var.instance_type}"
  iam_instance_profile        = "${aws_iam_instance_profile.node.name}"
  user_data                   = "${data.template_file.worker-userdata.rendered}"
  security_groups             = ["${aws_security_group.kubernetes-node.id}"]
  key_name                    = "${var.key_name}"
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "node" {
  name                = "${var.node_name}-node-asg"
  vpc_zone_identifier = "${data.aws_subnet_ids.node_subnet_ids.ids}"
  #vpc_zone_identifier = "${aws_subnet.private.*.id}"
  desired_capacity          = "2"
  min_size                  = "2"
  max_size                  = "3"
  health_check_type         = "EC2"
  force_delete              = false
  wait_for_capacity_timeout = 0
  launch_configuration      = "${aws_launch_configuration.node.name}"

  tags = [
    {
      key                 = "Name"
      value               = "${var.node_name}-dev"
      propagate_at_launch = true
    },
    {
      key                 = "environment"
      value               = "${var.environment}"
      propagate_at_launch = true
    },
    {
      key                 = "role"
      value               = "node"
      propagate_at_launch = true
    },
    {
      key                 = "kubernetes.io/cluster/${var.name}-${var.environment}"
      value               = "owned"
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/cluster-autoscaler/enabled"
      propagate_at_launch = true
      value               = "True"
    },
    {
      key                 = "k8s.io/cluster-autoscaler/${var.name}-${var.environment}"
      propagate_at_launch = true
      value               = "True"
    },
  ]
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_security_group" "kubernetes-node" {
  name        = "kubernetes-node"
  description = "Allow inbound ssh traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(map("Name", "${format("%s-%s-%s", var.node_name, var.environment, element(split("-", var.availability_zones[0]), 2))}"), map("kubernetes.io/cluster/${var.name}-${var.environment}", "owned"))}"
}
