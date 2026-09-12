variable "project_name"{
    description = "goad tracker used for resource naming"
    type = string
}

variable "vpc_cidr"{
    description = "CIDR block fot the vpc"
    type = string
    default = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones used by the VPC"
  type        = list(string)
}

variable "single_nat_gateway"{
    description = "Use a single NAT GATEway for cost optimization"
    type = bool
    default = true
}