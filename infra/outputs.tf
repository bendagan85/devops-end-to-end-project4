output "jenkins_public_ip" {
  value = aws_instance.jenkins_server.public_ip
}

output "app_public_ip" {
  value = aws_instance.app_server.public_ip
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.app_repo.repository_url
}

output "s3_artifacts_bucket" {
  description = "The name of the S3 bucket for artifacts"
  value       = aws_s3_bucket.artifacts.id
}