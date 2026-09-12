
# FRONTEND INSTANCE PROFILE


output "frontend_instance_profile_name" {
  description = "IAM instance profile name for frontend EC2 instances"

  value = aws_iam_instance_profile.frontend.name
}



# BACKEND INSTANCE PROFILE


output "backend_instance_profile_name" {
  description = "IAM instance profile name for backend EC2 instances"

  value = aws_iam_instance_profile.backend.name
}



# FRONTEND ROLE ARN


output "frontend_role_arn" {
  description = "ARN of the frontend EC2 IAM role"

  value = aws_iam_role.frontend.arn
}



# BACKEND ROLE ARN


output "backend_role_arn" {
  description = "ARN of the backend EC2 IAM role"

  value = aws_iam_role.backend.arn
}



# JENKINS INSTANCE PROFILE


output "jenkins_instance_profile_name" {
  description = "IAM instance profile name for Jenkins EC2"

  value = aws_iam_instance_profile.jenkins.name
}



# JENKINS ROLE ARN


output "jenkins_role_arn" {
  description = "ARN of the Jenkins IAM role"

  value = aws_iam_role.jenkins.arn
}