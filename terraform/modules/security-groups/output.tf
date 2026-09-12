output "public_alb_security_group_id" {
  description = "Security group ID for the public ALB"
  value       = aws_security_group.public_alb.id
}

output "frontend_security_group_id" {
  description = "Security group ID for frontend instances"
  value       = aws_security_group.frontend.id
}

output "internal_alb_security_group_id" {
  description = "Security group ID for the internal ALB"
  value       = aws_security_group.internal_alb.id
}

output "backend_security_group_id" {
  description = "Security group ID for backend instances"
  value       = aws_security_group.backend.id
}

output "database_security_group_id" {
  description = "Security group ID for PostgreSQL"
  value       = aws_security_group.database.id
}

output "jenkins_security_group_id" {
  description = "Security group ID for Jenkins"
  value       = aws_security_group.jenkins.id
}