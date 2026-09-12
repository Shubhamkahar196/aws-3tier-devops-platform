
# FRONTEND IAM ROLE


resource "aws_iam_role" "frontend" {
  name = "${var.project_name}-frontend-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name    = "${var.project_name}-frontend-role"
    Project = var.project_name
    Tier    = "frontend"
  }
}



# BACKEND IAM ROLE


resource "aws_iam_role" "backend" {
  name = "${var.project_name}-backend-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name    = "${var.project_name}-backend-role"
    Project = var.project_name
    Tier    = "backend"
  }
}



# FRONTEND ECR READ PERMISSION


resource "aws_iam_role_policy_attachment" "frontend_ecr" {
  role = aws_iam_role.frontend.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}



# BACKEND ECR READ PERMISSION


resource "aws_iam_role_policy_attachment" "backend_ecr" {
  role = aws_iam_role.backend.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}



# BACKEND SECRETS MANAGER POLICY


resource "aws_iam_policy" "backend_secrets" {
  name = "${var.project_name}-backend-secrets-policy"

  description = "Allow backend EC2 instances to read the RDS credentials secret"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue"
        ]

        Resource = var.db_secret_arn
      }
    ]
  })

  tags = {
    Name    = "${var.project_name}-backend-secrets-policy"
    Project = var.project_name
    Tier    = "backend"
  }
}



# ATTACH SECRETS POLICY TO BACKEND


resource "aws_iam_role_policy_attachment" "backend_secrets" {
  role = aws_iam_role.backend.name

  policy_arn = aws_iam_policy.backend_secrets.arn
}



# FRONTEND INSTANCE PROFILE


resource "aws_iam_instance_profile" "frontend" {
  name = "${var.project_name}-frontend-instance-profile"

  role = aws_iam_role.frontend.name

  tags = {
    Name    = "${var.project_name}-frontend-instance-profile"
    Project = var.project_name
    Tier    = "frontend"
  }
}



# BACKEND INSTANCE PROFILE


resource "aws_iam_instance_profile" "backend" {
  name = "${var.project_name}-backend-instance-profile"

  role = aws_iam_role.backend.name

  tags = {
    Name    = "${var.project_name}-backend-instance-profile"
    Project = var.project_name
    Tier    = "backend"
  }
}



# JENKINS IAM ROLE


resource "aws_iam_role" "jenkins" {
  name = "${var.project_name}-jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name    = "${var.project_name}-jenkins-role"
    Project = var.project_name
    Tier    = "cicd"
  }
}

resource "aws_iam_role_policy_attachment" "jenkins_ssm" {
  role       = aws_iam_role.jenkins.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}



# JENKINS ECR POLICY

resource "aws_iam_policy" "jenkins_ecr" {
  name        = "${var.project_name}-jenkins-ecr-policy"
  description = "Allow Jenkins to push Docker images to project ECR repositories"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken"
        ]

        Resource = "*"
      },
      {
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]

        Resource = [
          var.frontend_ecr_repository_arn,
          var.backend_ecr_repository_arn
        ]
      }
    ]
  })

  tags = {
    Name    = "${var.project_name}-jenkins-ecr-policy"
    Project = var.project_name
    Tier    = "cicd"
  }
}



# ATTACH ECR POLICY TO JENKINS


resource "aws_iam_role_policy_attachment" "jenkins_ecr" {
  role = aws_iam_role.jenkins.name

  policy_arn = aws_iam_policy.jenkins_ecr.arn
}



# JENKINS INSTANCE PROFILE

resource "aws_iam_instance_profile" "jenkins" {
  name = "${var.project_name}-jenkins-instance-profile"

  role = aws_iam_role.jenkins.name

  tags = {
    Name    = "${var.project_name}-jenkins-instance-profile"
    Project = var.project_name
    Tier    = "cicd"
  }
}