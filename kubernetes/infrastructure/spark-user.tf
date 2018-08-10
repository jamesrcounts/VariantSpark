resource "aws_iam_group" "spark" {
  name = "spark"
}

resource "aws_iam_group_policy_attachment" "ec2FullAccess" {
  group      = "${aws_iam_group.spark.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_group_policy_attachment" "route53FullAccess" {
  group      = "${aws_iam_group.spark.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}

resource "aws_iam_group_policy_attachment" "s3FullAccess" {
  group      = "${aws_iam_group.spark.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_group_policy_attachment" "iamFullAccess" {
  group      = "${aws_iam_group.spark.name}"
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

resource "aws_iam_group_policy_attachment" "vpcFullAccess" {
  group      = "${aws_iam_group.spark.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

resource "aws_iam_user" "spark" {
  name = "spark"
}

resource "aws_iam_group_membership" "spark_membership" {
  group = "${aws_iam_group.spark.name}"
  name  = "spark_membership"
  users = ["${aws_iam_user.spark.name}"]
}

resource "aws_iam_access_key" "spark_access_key" {
  user = "${aws_iam_user.spark.name}"
}
