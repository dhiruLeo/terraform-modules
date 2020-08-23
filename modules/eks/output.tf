# outputs
locals {
  kubeconfig = <<KUBECONFIG


apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.aws-eks.endpoint}
    certificate-authority-data: ${aws_eks_cluster.aws-eks.certificate_authority.0.data}
  name: ${aws_eks_cluster.aws-eks.arn}
contexts:
- context:
    cluster: ${aws_eks_cluster.aws-eks.arn}
    user: ${aws_eks_cluster.aws-eks.arn}
  name: ${aws_eks_cluster.aws-eks.arn}
current-context: ${aws_eks_cluster.aws-eks.arn}
kind: Config
preferences: {}
users:
- name: ${aws_eks_cluster.aws-eks.arn}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.name}-${var.environment}"
        env: null
KUBECONFIG
}

output "kubeconfig" {
  value = "${local.kubeconfig}"
}

# Join configuration

locals {
  config-map-aws-auth = <<CONFIGMAPAWSAUTH


apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.eks-node-role.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH
}

output "config-map-aws-auth" {
  value = "${local.config-map-aws-auth}"
}
