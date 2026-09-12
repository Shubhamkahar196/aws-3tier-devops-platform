output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "frontend_subnet_ids" {
  description = "IDs of frontend private subnets"
  value       = aws_subnet.frontend[*].id
}

output "backend_subnet_ids" {
  description = "IDs of backend private subnets"
  value       = aws_subnet.backend[*].id
}

output "database_subnet_ids" {
  description = "IDs of database private subnets"
  value       = aws_subnet.database[*].id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.main.id
}