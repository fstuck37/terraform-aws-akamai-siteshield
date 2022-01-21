resource "aws_s3_bucket" "bucket" {
  bucket_prefix = var.siteshield_name
  acl           = "private"
  tags          = var.tags
}