output "az-info" {
  value       = data.aws_availability_zones.available
  
}

output "vpc" {
  value      = data.aws_vpc.vpc.id # Data source reference
}

output "public-subnet-id" {
  value      = data.aws_subnets.Public_Subnets.id # Data source reference
}

