resource "aws_security_group" "variantspark_eks" {
  name        = "variantspark_eks_cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "variantspark_eks"
  }
}
