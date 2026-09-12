output "db_instance_id" {
  description = "RDS instance identifier"
  value       = aws_db_instance.postgres.id
}

output "db_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.postgres.address
}

output "db_port" {
  description = "RDS PostgreSQL port"
  value       = aws_db_instance.postgres.port
}

output "db_secret_arn" {
  description = "ARN of the AWS-managed RDS master credentials secret"
  value       = aws_db_instance.postgres.master_user_secret[0].secret_arn
}