output "access_key" {
  value = aws_iam_access_key.s3.id
}

output "access_secret_key" {
  value = aws_iam_access_key.s3.secret
}

# output "encrypted_secret" {
#   value = aws_iam_access_key.s3.encrypted_secret
# }
