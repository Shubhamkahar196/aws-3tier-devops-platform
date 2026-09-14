# ==========================================
# AMAZON LINUX 2023 AMI
# ==========================================

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}


# ==========================================
# FRONTEND LAUNCH TEMPLATE
# ==========================================

resource "aws_launch_template" "frontend" {
  name = "${var.project_name}-frontend-lt"

  image_id      = data.aws_ssm_parameter.al2023_ami.value
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.frontend_instance_profile_name
  }

  vpc_security_group_ids = [
    var.frontend_security_group_id
  ]

  user_data = base64encode(<<-EOF
    #!/bin/bash

    set -e

    # --------------------------------------
    # Install Docker
    # --------------------------------------

    dnf update -y
    dnf install -y docker

    systemctl enable docker
    systemctl start docker

    usermod -aG docker ec2-user


    # --------------------------------------
    # Login to Amazon ECR
    # --------------------------------------

    aws ecr get-login-password \
      --region ${var.aws_region} | \
      docker login \
      --username AWS \
      --password-stdin ${var.frontend_ecr_repository_url}


    # --------------------------------------
    # Pull Frontend Image
    # --------------------------------------

    docker pull ${var.frontend_ecr_repository_url}:${var.frontend_image_tag}


    # --------------------------------------
    # Remove Old Container
    # --------------------------------------

    docker rm -f goal-tracker-frontend 2>/dev/null || true


    # --------------------------------------
    # Run Frontend Container
    # --------------------------------------

    docker run -d \
      --name goal-tracker-frontend \
      --restart unless-stopped \
      -p 3000:3000 \
      -e BACKEND_URL=http://${var.internal_alb_dns_name}:8080 \
      ${var.frontend_ecr_repository_url}:${var.frontend_image_tag}

  EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${var.project_name}-frontend"
      Project     = var.project_name
      Tier        = "frontend"
      Environment = "dev"
    }
  }
}


# ==========================================
# FRONTEND AUTO SCALING GROUP
# ==========================================

resource "aws_autoscaling_group" "frontend" {
  name = "${var.project_name}-frontend-asg"

  min_size         = var.frontend_min_size
  desired_capacity = var.frontend_desired_capacity
  max_size         = var.frontend_max_size

  vpc_zone_identifier = var.frontend_subnet_ids

  target_group_arns = [
    var.frontend_target_group_arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.frontend.id
    version = "$Latest"
  }

    instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
      instance_warmup         = 120
    }


  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-frontend"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }

  tag {
    key                 = "Tier"
    value               = "frontend"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "dev"
    propagate_at_launch = true
  }
}


# ==========================================
# BACKEND LAUNCH TEMPLATE
# ==========================================

resource "aws_launch_template" "backend" {
  name = "${var.project_name}-backend-lt"

  image_id      = data.aws_ssm_parameter.al2023_ami.value
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.backend_instance_profile_name
  }

  vpc_security_group_ids = [
    var.backend_security_group_id
  ]

  user_data = base64encode(<<-EOF
    #!/bin/bash

    set -e

    # --------------------------------------
    # Install Docker + jq
    # --------------------------------------

    dnf update -y
    dnf install -y docker jq

    systemctl enable docker
    systemctl start docker

    usermod -aG docker ec2-user


    # --------------------------------------
    # Login to Amazon ECR
    # --------------------------------------

    aws ecr get-login-password \
      --region ${var.aws_region} | \
      docker login \
      --username AWS \
      --password-stdin ${var.backend_ecr_repository_url}


    # --------------------------------------
    # Get Database Credentials
    # --------------------------------------

    DB_SECRET=$(aws secretsmanager get-secret-value \
      --secret-id ${var.db_secret_arn} \
      --region ${var.aws_region} \
      --query SecretString \
      --output text)

    DB_USER=$(echo "$DB_SECRET" | jq -r '.username')
    DB_PASSWORD=$(echo "$DB_SECRET" | jq -r '.password')


    # --------------------------------------
    # Pull Backend Image
    # --------------------------------------

    docker pull ${var.backend_ecr_repository_url}:${var.backend_image_tag}


    # --------------------------------------
    # Remove Old Container
    # --------------------------------------

    docker rm -f goal-tracker-backend 2>/dev/null || true


    # --------------------------------------
    # Run Backend Container
    # --------------------------------------

    docker run -d \
      --name goal-tracker-backend \
      --restart unless-stopped \
      -p 8080:8080 \
      -e DB_HOST=${var.db_endpoint} \
      -e DB_PORT=5432 \
      -e DB_USER="$DB_USER" \
      -e DB_PASSWORD="$DB_PASSWORD" \
      -e DB_NAME=${var.db_name} \
      ${var.backend_ecr_repository_url}:${var.backend_image_tag}

  EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${var.project_name}-backend"
      Project     = var.project_name
      Tier        = "backend"
      Environment = "dev"
    }
  }
}


# ==========================================
# BACKEND AUTO SCALING GROUP
# ==========================================

resource "aws_autoscaling_group" "backend" {
  name = "${var.project_name}-backend-asg"

  min_size         = var.backend_min_size
  desired_capacity = var.backend_desired_capacity
  max_size         = var.backend_max_size

  vpc_zone_identifier = var.backend_subnet_ids

  target_group_arns = [
    var.backend_target_group_arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }

    instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
      instance_warmup         = 120
    }

    
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-backend"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }

  tag {
    key                 = "Tier"
    value               = "backend"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "dev"
    propagate_at_launch = true
  }
}