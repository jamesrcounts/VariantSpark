variable "cluster_name" {}

variable "public_subnets" {
  type = "list"
}

variable "worker_size" {
  default = "m4.large"
}

variable "spark_user_arn" {}
variable "vpc_id" {}
