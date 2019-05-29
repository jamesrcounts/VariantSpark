data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-*"] # previous AWS naming convention was "eks-worker-*"
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon Account ID
}

# This data source is included for ease of sample architecture deployment
# and can be swapped out as necessary.
data "aws_region" "current" {}

data "aws_caller_identity" "current" {}
