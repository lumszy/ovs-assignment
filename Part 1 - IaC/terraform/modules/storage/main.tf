resource "aws_s3_bucket" "student_uploads" {
  bucket = "${var.project_name}-${var.environment}-student-uploads"

  tags = {
    Name = "${var.project_name}-${var.environment}-student-uploads"
  }
}

resource "aws_s3_bucket_versioning" "student_uploads" {
  bucket = aws_s3_bucket.student_uploads.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "student_uploads" {
  bucket = aws_s3_bucket.student_uploads.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "student_uploads" {
  bucket = aws_s3_bucket.student_uploads.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
