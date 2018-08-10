resource "aws_security_group" "variantspark_node" {
  name        = "variantspark_eks_node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
     "Name", "variantspark_eks_node",
     "kubernetes.io/cluster/${var.cluster_name}", "owned"
    )
  }"
}

resource "aws_security_group_rule" "variantspark_eks_node_ingress_self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.variantspark_node.id}"
  source_security_group_id = "${aws_security_group.variantspark_node.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "variantspark_eks_node_ingress_cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.variantspark_node.id}"
  source_security_group_id = "${aws_security_group.variantspark_eks.id}"
  to_port                  = 65535
  type                     = "ingress"
}
