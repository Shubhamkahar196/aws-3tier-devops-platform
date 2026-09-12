resource "aws_security_group" "public_alb"{
    name  = "${var.project_name}-public-alb-sg"
     description = "Security group for public Application Load Balancer"
     vpc_id = var.vpc_id

     tags = {
         Name    = "${var.project_name}-public-alb-sg"
    Project = var.project_name
    Tier    = "load-balancer"
     }
}

resource "aws_vpc_security_group_ingress_rule" "public_alb_http"{
    security_group_id =  aws_security_group.public_alb.id

    cidr_ipv4 = "0.0.0.0/0"
    from_port = 80
    ip_protocol = "tcp"
    to_port = 80
}

resource "aws_vpc_security_group_ingress_rule" "public_alb_https"{
    security_group_id = aws_security_group.public_alb.id

    cidr_ipv4 = "0.0.0.0/0"
    from_port = 443
    ip_protocol = "tcp"
    to_port = 443
}

resource "aws_vpc_security_group_egress_rule" "public_alb_all"{
    security_group_id = aws_security_group.public_alb.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "-1"
}


# frontend security group

resource "aws_security_group" "frontend"{
    name = "${var.project_name}-frontend-sg"
     description = "Security group for frontend application servers"
  vpc_id      = var.vpc_id

  tags = {
    Name    = "${var.project_name}-frontend-sg"
    Project = var.project_name
    Tier    = "frontend"
  }
}

resource "aws_vpc_security_group_ingress_rule" "frontend_from_alb"{
    security_group_id = aws_security_group.frontend.id

    referenced_security_group_id = aws_security_group.public_alb.id

    from_port = 3000
    ip_protocol = "tcp"
    to_port = 3000
}

resource "aws_vpc_security_group_egress_rule" "frontend_all"{
    security_group_id = aws_security_group.frontend.id

    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "-1"
}


# internal ALB security group

resource "aws_security_group" "internal_alb"{
    name = "${var.project_name}-internal-alb-sg"
    description = "Security group for internal backend Application Load Balancer"
    vpc_id = var.vpc_id

    tags = {
        Name = "${var.project_name}-internal-alb-sg"
        Project = var.project_name
        Tier = "internal-load-balancer"
    }
}


resource "aws_vpc_security_group_ingress_rule" "internal_alb_from_frontend"{
    security_group_id = aws_security_group.internal_alb.id
    referenced_security_group_id = aws_security_group.frontend.id

    from_port = 8080
    ip_protocol = "tcp"
    to_port = 8080
}

resource "aws_vpc_security_group_egress_rule" "internal_alb_all" {
  security_group_id = aws_security_group.internal_alb.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}


# backend security group

resource "aws_security_group" "backend"{
    name = "${var.project_name}-backend-sg"
    description = "Security group for backend application servers"
  vpc_id      = var.vpc_id

  tags = {
    Name    = "${var.project_name}-backend-sg"
    Project = var.project_name
    Tier    = "backend"
  }
}

resource "aws_vpc_security_group_ingress_rule" "backend_from_internal_alb"{
    security_group_id = aws_security_group.backend.id

    referenced_security_group_id = aws_security_group.internal_alb.id

    from_port = 8080
    ip_protocol = "tcp"
    to_port = 8080
}

resource "aws_vpc_security_group_egress_rule" "backend_all" {
  security_group_id = aws_security_group.backend.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}


# database security group

resource "aws_security_group" "database"{
    name = "${var.project_name}-database-sg"
    description = "Security group for PostgreSQL database"
    vpc_id= var.vpc_id

    tags ={
        Name = "${var.project_name}-database-sg"
        Project = var.project_name
        Tier = "database"
    }
}

resource "aws_vpc_security_group_ingress_rule" "database_from_backend" {
    security_group_id = aws_security_group.database.id

    referenced_security_group_id = aws_security_group.backend.id

    from_port = 5432
    ip_protocol = "tcp"
    to_port = 5432
}

resource "aws_vpc_security_group_egress_rule" "database_all" {
  security_group_id = aws_security_group.database.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}


# jenkins security group

resource "aws_security_group" "jenkins"{
    name = "${var.project_name}-jenkins-sg"
    description = "Security group for jenkins CI/CD server"
    vpc_id = var.vpc_id

    tags = {
        Name = "${var.project_name}-jenkins-sg"
        Project = var.project_name
        Tier = "cicd"
    }
}


# jenkins HTTP access

resource "aws_vpc_security_group_ingress_rule" "jenkins_http" {
  security_group_id = aws_security_group.jenkins.id

  cidr_ipv4 = "0.0.0.0/0"

  from_port = 8080
  to_port   = 8080
  ip_protocol = "tcp"
}

# JENKINS SSH ACCESS
resource "aws_vpc_security_group_ingress_rule" "jenkins_ssh" {
  security_group_id = aws_security_group.jenkins.id

  cidr_ipv4 = "0.0.0.0/0"

  from_port = 22
  to_port   = 22
  ip_protocol = "tcp"
}
# JENKINS EGRESS
resource "aws_vpc_security_group_egress_rule" "jenkins_all" {
  security_group_id = aws_security_group.jenkins.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}