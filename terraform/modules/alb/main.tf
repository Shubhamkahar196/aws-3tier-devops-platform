
# PUBLIC APPLICATION LOAD BALANCER


resource "aws_lb" "public" {
  name               = "${var.project_name}-public-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    var.public_alb_security_group_id
  ]

  subnets = var.public_subnet_ids

  tags = {
    Name    = "${var.project_name}-public-alb"
    Project = var.project_name
    Tier    = "load-balancer"
  }
}



# FRONTEND TARGET GROUP


resource "aws_lb_target_group" "frontend" {
  name        = "${var.project_name}-frontend-tg"
  port        = 3000
  protocol    = "HTTP"
  target_type = "instance"

  vpc_id = var.vpc_id

  health_check {
    enabled  = true
    protocol = "HTTP"
    port     = "3000"
    path     = "/"
  }

  tags = {
    Name    = "${var.project_name}-frontend-tg"
    Project = var.project_name
    Tier    = "frontend"
  }
}



# PUBLIC ALB LISTENER


resource "aws_lb_listener" "public_http" {
  load_balancer_arn = aws_lb.public.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}



# INTERNAL APPLICATION LOAD BALANCER


resource "aws_lb" "internal" {
  name               = "${var.project_name}-internal-alb"
  internal           = true
  load_balancer_type = "application"

  security_groups = [
    var.internal_alb_security_group_id
  ]

  subnets = var.frontend_subnet_ids

  tags = {
    Name    = "${var.project_name}-internal-alb"
    Project = var.project_name
    Tier    = "internal-load-balancer"
  }
}



# BACKEND TARGET GROUP


resource "aws_lb_target_group" "backend" {
  name        = "${var.project_name}-backend-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"

  vpc_id = var.vpc_id

  health_check {
    enabled  = true
    protocol = "HTTP"
    port     = "8080"
    path     = "/"
  }

  tags = {
    Name    = "${var.project_name}-backend-tg"
    Project = var.project_name
    Tier    = "backend"
  }
}



# INTERNAL ALB LISTENER


resource "aws_lb_listener" "internal_http" {
  load_balancer_arn = aws_lb.internal.arn

  port     = 8080
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}