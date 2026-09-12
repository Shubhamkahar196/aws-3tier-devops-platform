variable "project_name" {
  description = "Project name used for ALB resource naming"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the load balancers will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the internet-facing ALB"
  type        = list(string)
}

variable "frontend_subnet_ids" {
  description = "Private frontend subnet IDs for the internal ALB"
  type        = list(string)
}

variable "public_alb_security_group_id" {
  description = "Security group ID for the public ALB"
  type        = string
}

variable "internal_alb_security_group_id" {
  description = "Security group ID for the internal ALB"
  type        = string
}