variable "cluster_name" {}

variable "public_subnets" {
  type = "list"
}

variable "worker_size" {
  default = "r4.4xlarge"
}

variable "spark_user_arn" {}
variable "vpc_id" {}

variable "caller_profile" {
  default = "default"
}
