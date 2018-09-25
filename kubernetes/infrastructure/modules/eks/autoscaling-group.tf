# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  demo-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.variantspark.endpoint}' --b64-cluster-ca '${aws_eks_cluster.variantspark.certificate_authority.0.data}' '${var.cluster_name}'
USERDATA
}

resource "aws_launch_configuration" "variantspark" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.variantspark_node.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "${var.worker_size}"
  name_prefix                 = "variantspark-eks"
  security_groups             = ["${aws_security_group.variantspark_node.id}"]
  user_data_base64            = "${base64encode(local.demo-node-userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "variantspark" {
  desired_capacity     = 12
  launch_configuration = "${aws_launch_configuration.variantspark.id}"
  max_size             = 12
  min_size             = 1
  name                 = "variantspark-eks"
  vpc_zone_identifier  = ["${var.public_subnets}"]

  tag {
    key                 = "Name"
    value               = "variantspark-eks"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}
