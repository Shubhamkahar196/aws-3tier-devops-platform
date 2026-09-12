variable "project_name" {
  description = "Project name used for IAM resource naming"
  type        = string
}

variable "db_secret_arn" {
  description = "ARN of the RDS master credentials secret"
  type        = string
}

variable "frontend_ecr_repository_arn" {
  description = "ARN of the frontend ECR repository"
  type        = string
}

variable "backend_ecr_repository_arn" {
  description = "ARN of the backend ECR repository"
  type        = string
}