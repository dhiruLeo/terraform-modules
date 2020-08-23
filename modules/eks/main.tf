provider "aws" {
  region                  = "${var.region}"
  shared_credentials_file = "${var.shared_credentials_file}"
  profile                 = "${var.profile}"
  version                 = ">=2.0.0"
}

# Create EKS cluster
resource "aws_eks_cluster" "aws-eks" {
  name     = "${var.name}-${var.environment}"
  role_arn = "${aws_iam_role.eks-master-role.arn}"
  version  = "${var.k8s_master_version}"

  vpc_config {
    security_group_ids = ["${data.aws_security_groups.eks-master.ids}"]
    subnet_ids         = ["${concat(data.aws_subnet_ids.public_subnet_ids.ids, data.aws_subnet_ids.master_subnet_ids.ids)}"]
  }

  depends_on = [
    "aws_iam_role.eks-master-role",
    "aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.eks-cluster-AmazonEKSServicePolicy",
  ]
}

resource "aws_launch_configuration" "aws-eks-node-lc" {
  associate_public_ip_address = "false"
  iam_instance_profile        = "${aws_iam_instance_profile.eks-node.name}"
  image_id                    = "${var.node-ami-id}"
  instance_type               = "${var.node-instance-type}"
  name_prefix                 = "eks-node"
  key_name                    = "${var.key}"
  security_groups             = ["${data.aws_security_groups.eks-node.ids}"]
  user_data                   = "${data.template_file.userdata-eks-node.rendered}"

  root_block_device = {
    volume_type           = "${var.volume_type}"
    volume_size           = "${var.node_root_volume_size}"
    delete_on_termination = false
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = ["aws_eks_cluster.aws-eks"]
}

resource "aws_autoscaling_group" "aws-eks-node-asg" {
  name                 = "${var.name}-${var.environment}-eks-node-asg-primary"
  launch_configuration = "${aws_launch_configuration.aws-eks-node-lc.id}"
  vpc_zone_identifier  = ["${data.aws_subnet_ids.node_subnet_ids.ids}"]

  min_size         = "${var.minimum-node}"
  desired_capacity = "${var.desired-node}"
  max_size         = "${var.maximum-node}"

  tags = [
    {
      key                 = "Name"
      value               = "${var.name}-${var.environment}"
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

  depends_on = ["aws_eks_cluster.aws-eks"]
}
