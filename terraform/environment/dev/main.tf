terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "ecr" {
  source = "../../modules/ecr"

  project_name = var.project_name
}

# vpc

module "vpc" {
  source = "../../modules/vpc"

  project_name       = var.project_name
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["ap-south-1a", "ap-south-1b"]
  single_nat_gateway = true
}

# security group

module "security_groups" {
  source = "../../modules/security-groups"

  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
}

# rds

module "rds" {
  source = "../../modules/rds"

  project_name               = var.project_name
  vpc_id                     = module.vpc.vpc_id
  database_subnet_ids        = module.vpc.database_subnet_ids
  database_security_group_id = module.security_groups.database_security_group_id

  db_name        = "goalsdb"
  db_username    = "goaltracker"
  instance_class = "db.t3.micro"
  multi_az       = false
}

# iam

module "iam" {
  source = "../../modules/iam"

  project_name  = var.project_name
  db_secret_arn = module.rds.db_secret_arn

  frontend_ecr_repository_arn = module.ecr.frontend_repository_arn

  backend_ecr_repository_arn = module.ecr.backend_repository_arn
}

# alb
module "alb" {
  source = "../../modules/alb"

  project_name = var.project_name

  vpc_id = module.vpc.vpc_id

  public_subnet_ids = module.vpc.public_subnet_ids

  frontend_subnet_ids = module.vpc.frontend_subnet_ids

  public_alb_security_group_id = module.security_groups.public_alb_security_group_id

  internal_alb_security_group_id = module.security_groups.internal_alb_security_group_id
}



# EC2
module "ec2" {
  source = "../../modules/ec2"

  project_name = var.project_name
  aws_region   = var.aws_region


  # Subnets


  frontend_subnet_ids = module.vpc.frontend_subnet_ids
  backend_subnet_ids  = module.vpc.backend_subnet_ids


  # Security Groups


  frontend_security_group_id = module.security_groups.frontend_security_group_id
  backend_security_group_id  = module.security_groups.backend_security_group_id


  # IAM


  frontend_instance_profile_name = module.iam.frontend_instance_profile_name
  backend_instance_profile_name  = module.iam.backend_instance_profile_name


  # ALB


  frontend_target_group_arn = module.alb.frontend_target_group_arn
  backend_target_group_arn  = module.alb.backend_target_group_arn

  internal_alb_dns_name = module.alb.internal_alb_dns_name


  # ECR


  frontend_ecr_repository_url = module.ecr.frontend_repository_url
  backend_ecr_repository_url  = module.ecr.backend_repository_url

  frontend_image_tag = "e07ce7d99a99"
  backend_image_tag  = "e07ce7d99a99"


  # Database


  db_endpoint   = module.rds.db_endpoint
  db_secret_arn = module.rds.db_secret_arn
  db_name       = "goalsdb"


  # EC2


  instance_type = "t3.micro"


  # Frontend ASG


  frontend_min_size         = 1
  frontend_desired_capacity = 2
  frontend_max_size         = 2


  # Backend ASG


  backend_min_size         = 1
  backend_desired_capacity = 2
  backend_max_size         = 2
}


# jenkins 
module "jenkins" {
  source = "../../modules/jenkins"

  project_name = var.project_name

  vpc_id = module.vpc.vpc_id

  public_subnet_id = module.vpc.public_subnet_ids[0]

  jenkins_security_group_id = module.security_groups.jenkins_security_group_id

  jenkins_instance_profile_name = module.iam.jenkins_instance_profile_name

  instance_type = "t3.micro"
}