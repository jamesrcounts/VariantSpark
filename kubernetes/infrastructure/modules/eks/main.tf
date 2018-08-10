resource "aws_eks_cluster" "variantspark" {
  name     = "${var.cluster_name}"
  role_arn = "${aws_iam_role.eks_master.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.variantspark_eks.id}"]
    subnet_ids         = ["${var.public_subnets}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.eks_master_AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.variantspark_node_AmazonEKSWorkerNodePolicy",
  ]
}

resource "aws_security_group_rule" "variantspark_eks_node_https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.variantspark_eks.id}"
  source_security_group_id = "${aws_security_group.variantspark_node.id}"
  to_port                  = 443
  type                     = "ingress"
}

locals {
  kubernetes-admin-policy = <<KUBEADMINPOLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {}
    }
  ]
}
KUBEADMINPOLICY
}

resource "aws_iam_role" "kubeadmin" {
  name               = "KubernetesAdmin"
  description        = "Kubernetes administrator role (for Heptio Authenticator for AWS)."
  assume_role_policy = "${local.kubernetes-admin-policy}"
}
