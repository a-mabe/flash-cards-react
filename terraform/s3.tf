# Create the bucket
resource "aws_s3_bucket" "app_bucket" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    Project     = "${var.project_name}"
    Environment = "${var.environment}"
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.app_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Add the website files
module "website_files" {
  source   = "hashicorp/dir/template"
  base_dir = var.website_root
}

resource "aws_s3_object" "static_files" {
  for_each     = module.website_files.files
  bucket       = var.bucket_name
  key          = each.key
  content_type = each.value.content_type
  source       = each.value.source_path
  content      = each.value.content
  etag         = each.value.digests.md5
  depends_on = [
    aws_s3_bucket.app_bucket
  ]
}
