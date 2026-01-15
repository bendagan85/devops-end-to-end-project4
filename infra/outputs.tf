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

output "alb_dns_name" {
  value       = aws_lb.app_alb.dns_name
  description = "The DNS name of the ALB"
}

output "app_server_2_public_ip" {
  description = "Public IP of the second App Server (Green)"
  value       = aws_instance.app_server_2.public_ip
}