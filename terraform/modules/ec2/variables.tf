variable "project_name" {
  description = "Project name used for EC2 resource naming"
  type        = string
}

variable "aws_region" {
  description = "AWS region where resources are deployed"
  type        = string
}

# -----------------------------
# Subnets
# -----------------------------

variable "frontend_subnet_ids" {
  description = "Private frontend subnet IDs"
  type        = list(string)
}

variable "backend_subnet_ids" {
  description = "Private backend subnet IDs"
  type        = list(string)
}

# -----------------------------
# Security Groups
# -----------------------------

variable "frontend_security_group_id" {
  description = "Security group ID for frontend EC2 instances"
  type        = string
}

variable "backend_security_group_id" {
  description = "Security group ID for backend EC2 instances"
  type        = string
}

# -----------------------------
# IAM Instance Profiles
# -----------------------------

variable "frontend_instance_profile_name" {
  description = "IAM instance profile for frontend EC2 instances"
  type        = string
}

variable "backend_instance_profile_name" {
  description = "IAM instance profile for backend EC2 instances"
  type        = string
}

# -----------------------------
# ALB Target Groups
# -----------------------------

variable "frontend_target_group_arn" {
  description = "Frontend ALB target group ARN"
  type        = string
}

variable "backend_target_group_arn" {
  description = "Backend ALB target group ARN"
  type        = string
}

variable "internal_alb_dns_name" {
  description = "DNS name of the internal ALB"
  type        = string
}

# -----------------------------
# ECR
# -----------------------------

variable "frontend_ecr_repository_url" {
  description = "Frontend ECR repository URL"
  type        = string
}

variable "backend_ecr_repository_url" {
  description = "Backend ECR repository URL"
  type        = string
}

variable "frontend_image_tag" {
  description = "Docker image tag for frontend"
  type        = string
  default     = "1.0"
}

variable "backend_image_tag" {
  description = "Docker image tag for backend"
  type        = string
  default     = "1.0"
}

# -----------------------------
# EC2
# -----------------------------

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

# -----------------------------
# Frontend ASG
# -----------------------------

variable "frontend_min_size" {
  description = "Minimum frontend ASG capacity"
  type        = number
  default     = 1
}

variable "frontend_desired_capacity" {
  description = "Desired frontend ASG capacity"
  type        = number
  default     = 2
}

variable "frontend_max_size" {
  description = "Maximum frontend ASG capacity"
  type        = number
  default     = 2
}

# -----------------------------
# Backend ASG
# -----------------------------

variable "backend_min_size" {
  description = "Minimum backend ASG capacity"
  type        = number
  default     = 1
}

variable "backend_desired_capacity" {
  description = "Desired backend ASG capacity"
  type        = number
  default     = 2
}

variable "backend_max_size" {
  description = "Maximum backend ASG capacity"
  type        = number
  default     = 2
}

# -----------------------------
# Database
# -----------------------------

variable "db_endpoint" {
  description = "RDS PostgreSQL endpoint"
  type        = string
}

variable "db_secret_arn" {
  description = "ARN of the RDS credentials secret"
  type        = string
}

variable "db_name" {
  description = "Application database name"
  type        = string
  default     = "goalsdb"
}