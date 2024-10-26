resource "aws_s3_bucket" "sftp_bucket" {
  bucket = "projectsftp342"
}

data "aws_iam_policy_document" "s3_access_for_sftp_users" {
  statement {
    actions = ["s3:ListBucket"]
    resources = [aws_s3_bucket.sftp_bucket.arn]
  }

  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:GetObjectVersion",
      "s3:GetObjectACL",
      "s3:PutObjectACL"
    ]
    resources = ["${aws_s3_bucket.sftp_bucket.arn}/nikhilsftp/*"]
  }
}

resource "aws_iam_policy" "s3_access_policy" {
  name   = "sftp-specific-bucket-access"
  policy = data.aws_iam_policy_document.s3_access_for_sftp_users.json
}

resource "aws_iam_role" "sftp_role" {
  name               = "sftp"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Service = "transfer.amazonaws.com"
      }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "sftp_role_policy_attachment" {
  role       = aws_iam_role.sftp_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_transfer_server" "sftp_server" {
  identity_provider_type = "SERVICE_MANAGED"
  protocols              = ["SFTP"]
  endpoint_type          = "PUBLIC"
  logging_role           = aws_iam_role.sftp_role.arn
  tags = {
    Name = "projectsftp342"
  }
}
resource "aws_transfer_user" "sftp_user" {
  server_id           = aws_transfer_server.sftp_server.id
  user_name           = "nikhilsftp"  # Your SFTP username
  role                = aws_iam_role.sftp_role.arn  # Ensure this role exists and has the correct policies
  home_directory_type = "LOGICAL"  # Do not set home_directory

  home_directory_mappings {
    entry  = "/"  # The logical directory path (root)
    target = "/${aws_s3_bucket.sftp_bucket.bucket}/nikhilsftp"  # Maps to the S3 bucket path
  }
  }


resource "aws_transfer_ssh_key" "sftp_ssh_key" {
  server_id = aws_transfer_server.sftp_server.id
  user_name = aws_transfer_user.sftp_user.user_name
  body      = file("./nikhil.pub")
}