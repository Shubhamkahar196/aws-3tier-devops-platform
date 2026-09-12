variable "project_name"{
    description = "project name"
    type = string
}

variable "vpc_id"{
    description = "VPC ID"
    type = string
}

variable "database_subnet_ids"{
    description = "Private database subnets IDS"
    type = list(string)
}

variable "database_security_group_id" {
  description = "Security group ID for PostgreSQL"
  type = string
}

variable "db_name"{
    description = "PostgreSQL database name"
    type = string
    default = "goalsdb"
}

variable "db_username"{
    description = "PostgreSQL master username"
    type = string
    default = "goaltracker"
}

variable "instance_class"{
description = "RDS instance class"
type = string
default = "db.t3.micro"
}

variable "multi_az"{
    description = "Enable Multi-AZ deployment"
    type = bool
    default = false
}
