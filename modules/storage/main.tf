resource "aws_s3_bucket" "this" {
  bucket = "${var.project_name}-${var.bucket_name}"

  tags = {
    Name = "${var.project_name}-${var.bucket_name}"
  }
}
