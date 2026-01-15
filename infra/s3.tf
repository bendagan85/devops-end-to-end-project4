# באקט לאחסון ארטיפקטים (Build artifacts)
resource "aws_s3_bucket" "artifacts" {
  bucket = "my-project-artifacts-${random_string.suffix.result}" # שם ייחודי בעזרת סיומת רנדומלית
  
  tags = {
    Name        = "Project-Artifacts"
    Environment = "DevOps-Task"
  }
}

# מניעת גישה ציבורית (Best Practice)
resource "aws_s3_bucket_public_access_block" "artifacts_block" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# יצירת סיומת רנדומלית כדי ששם הבאקט יהיה ייחודי בעולם
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}