output "bucket_name" {
  description = "Name of the student upload bucket."
  value       = aws_s3_bucket.student_uploads.bucket
}

output "bucket_arn" {
  description = "ARN of the student upload bucket."
  value       = aws_s3_bucket.student_uploads.arn
}
