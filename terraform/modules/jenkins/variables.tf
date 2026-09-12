variable "project_name" {
  description = "Project name used for Jenkins resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for Jenkins"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet where Jenkins EC2 will run"
  type        = string
}

variable "jenkins_security_group_id" {
  description = "Security group ID for Jenkins"
  type        = string
}

variable "jenkins_instance_profile_name" {
  description = "IAM instance profile for Jenkins EC2"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for Jenkins"
  type        = string
  default     = "t3.micro"
}