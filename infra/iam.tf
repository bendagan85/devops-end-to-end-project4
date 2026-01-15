# יצירת ה-Role
resource "aws_iam_role" "jenkins_role" {
  name = "jenkins_ecr_s3_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# הצמדת פוליסי של ECR ו-S3 ל-Role
resource "aws_iam_role_policy_attachment" "jenkins_ecr_full" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_role_policy_attachment" "jenkins_s3_full" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# יצירת Instance Profile שיוצמד ל-EC2
resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "jenkins_instance_profile"
  role = aws_iam_role.jenkins_role.name
}