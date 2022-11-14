resource "aws_iam_access_key" "s3" {
  user = aws_iam_user.s3.name
}

resource "aws_iam_user" "s3" {
  name = "${var.application_name}-${terraform.workspace}-user"
  path = "/system/"
}

resource "aws_iam_user_policy" "s3_full" {
  name = "${aws_iam_user.s3.name}-policy"
  user = aws_iam_user.s3.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "s3:*",
          "s3-object-lambda:*"
      ],
      "Resource": "${var.assets_bucket_arn}/*"
    }
  ]
}
EOF
}
