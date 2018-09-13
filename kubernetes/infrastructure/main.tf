// OPTIONAL You can use a backend configuration like the one below to store your terraform state remotely
// otherwise the state will be stored locally.  State may contain secrets and should not be stored in
// source control
//terraform {
//  backend "s3" {
//    bucket  = "example-bucket"
//    key     = "variantspark/tfstate"
//    region  = "us-west-2"
//  }
//}

// Configures AWS as a cloud provider

provider "aws" {
  region  = "${var.default_region}"
  profile = "${var.default_profile}"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Terraform                                   = "true"
    Environment                                 = "dev"
    Name                                        = "${var.cluster_name}-node"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

module "eks" {
  source         = "modules/eks"
  cluster_name   = "${var.cluster_name}"
  public_subnets = "${module.vpc.public_subnets}"
  spark_user_arn = "${aws_iam_user.spark.arn}"
  vpc_id         = "${module.vpc.vpc_id}"
}

resource "local_file" "kubeconfig" {
  filename = "out/config"
  content  = "${module.eks.kubeconfig}"

  provisioner "local-exec" {
    command = "cp out/config ~/.kube/config"
  }
}

resource "local_file" "setup_yaml" {
  filename = "out/setup.yaml"
  content  = "${module.eks.kubernetes_setup}"
}
