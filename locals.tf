locals {
    Az-info= slice(data.aws_availability_zones.available.names,0,2)
   common_tags = {
      Project = var.project
      Environment = var.environment
      Terraform = "true"
    }
}