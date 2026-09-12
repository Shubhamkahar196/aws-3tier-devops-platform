output "frontend_ecr_repository_url" {
  description = "ECR repository URL for the frontend"
  value       = module.ecr.frontend_repository_url
}

output "backend_ecr_repository_url" {
  description = "ECR repository URL for the backend"
  value       = module.ecr.backend_repository_url
}

output "public_alb_dns_name" {
  description = "Public ALB DNS name"
  value       = module.alb.public_alb_dns_name
}

output "internal_alb_dns_name" {
  description = "Internal ALB DNS name"
  value       = module.alb.internal_alb_dns_name
}

output "frontend_asg_name" {
  description = "Frontend Auto Scaling Group name"
  value       = module.ec2.frontend_asg_name
}

output "backend_asg_name" {
  description = "Backend Auto Scaling Group name"
  value       = module.ec2.backend_asg_name
}

output "jenkins_public_ip" {
  description = "Jenkins public IP address"
  value       = module.jenkins.jenkins_public_ip
}

output "jenkins_public_dns" {
  description = "Jenkins public DNS name"
  value       = module.jenkins.jenkins_public_dns
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = module.rds.db_endpoint
}

output "rds_secret_arn" {
  description = "RDS credentials secret ARN"
  value       = module.rds.db_secret_arn
  sensitive   = true
}