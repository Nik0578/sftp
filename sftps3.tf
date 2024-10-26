module "s3" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.2.1" # Replace with the latest stable version

  bucket = "projectsftp342" # Corrected from bucket-name


  versioning = { # Corrected from versioning-enable
    enabled = true
  }
}
