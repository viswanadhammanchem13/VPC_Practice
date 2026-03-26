output "az-info" {
  value       = data.aws_availability_zones.available
  
}

output "vpc-id" {
  value      = aws_vpc.main.id # Data source reference
}

output "public-subnet" {
  value      = aws_subnet.public[*].id
}

output "private-subnet" {
  value      = aws_subnet.private[*].id
}
output "database-subnet" {
  value      = aws_subnet.database[*].id
}
