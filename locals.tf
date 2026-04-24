locals {
    Az-info= slice(data.aws_availability_zones.available.names,0,2)
   common_tags = {
      poject = var.project
      evironment = var.environment
      Terraform = "true"
    }
}