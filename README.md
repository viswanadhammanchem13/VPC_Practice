📘 Terraform AWS VPC Module – README
📌 Overview

This Terraform module provisions a complete AWS networking setup including:

VPC
Public, Private, and Database subnets
Internet Gateway (IGW)
NAT Gateway
Route Tables & Associations
Elastic IP
Optional VPC Peering with default VPC
SSM Parameter Store integration (in caller module)

This design follows a 3-tier architecture:
Public → Internet-facing resources
Private → Application layer
Database → Secure backend layer

🧱 Architecture Flow
VPC
 ├── Public Subnets → IGW → Internet
 ├── Private Subnets → NAT Gateway → Internet
 ├── Database Subnets → NAT Gateway (no direct internet)
 └── Optional → Peering with Default VPC

📂 Module Structure
1. main.tf

Defines all core infrastructure resources.

2. data.tf

Fetches existing AWS resources like:

Default VPC
Availability Zones
Default Route Table

3. locals.tf

Reusable computed values:

AZ selection
Common tags

4. outputs.tf

Exports values to calling module.

5. peering.tf

Handles optional VPC peering.

6. variables.tf

Defines all inputs.

⚙️ Resources Explained
🌐 VPC
resource "aws_vpc" "main"
Purpose:

Creates isolated network.

Important Parameters:
cidr_block ✅ Required → Defines IP range
instance_tenancy → Default or dedicated (optional)
enable_dns_hostnames → Required for private services
🌍 Internet Gateway
resource "aws_internet_gateway" "main"
Purpose:

Allows public subnets to access internet.

Required:
vpc_id
💡 Elastic IP
resource "aws_eip" "elastic_ip"
Purpose:

Static IP for NAT Gateway.

Required:
domain = "vpc"
🚪 Subnets
Public Subnets
resource "aws_subnet" "public"
Private Subnets
resource "aws_subnet" "private"
Database Subnets
resource "aws_subnet" "database"
Key Parameters:
cidr_block ✅ Required
availability_zone ✅ Required
map_public_ip_on_launch → Only for public subnet
🔁 NAT Gateway
resource "aws_nat_gateway" "nat_gw"
Purpose:

Allows private/database subnets to access internet securely.

Required:
allocation_id (Elastic IP)
subnet_id (Public subnet)
Important:
depends_on = [aws_internet_gateway.main]

Ensures proper creation order.

🛣️ Route Tables
Public Route Table
Routes → Internet via IGW
Private & Database Route Tables
Routes → Internet via NAT Gateway
🔗 Route Table Associations

Links subnets to route tables.

🔄 VPC Peering (Optional)
resource "aws_vpc_peering_connection"
Purpose:

Connects your VPC with default VPC.

Controlled by:
variable "is_peering_required"
If enabled:
Adds routes in:
Public RT
Private RT
Database RT
Default VPC RT
📥 Data Sources
data "aws_availability_zones"
Fetch available AZs
data "aws_vpc" "default"
Fetch default VPC
data "aws_route_table" "main"
Fetch default route table
🧮 Locals
locals {
  Az-info = slice(data.aws_availability_zones.available.names, 0, 2)
}
Purpose:
Select first 2 AZs dynamically
Avoid hardcoding
📤 Outputs
Output	Description
vpc-id	Created VPC ID
public-subnet	Public subnet IDs
private-subnet	Private subnet IDs
database-subnet	DB subnet IDs
default_vpc	Default VPC ID
default_route_table	Default route table
🧾 Variables (Inputs)
✅ Required Variables
Variable	Description
project	Project name
environment	Environment (dev/prod)
public_subnet_cidrs	Public subnet CIDRs
private_subnet_cidrs	Private subnet CIDRs
database_subnet_cidrs	DB subnet CIDRs
⚙️ Optional Variables
Variable	Default	Purpose
cidr_block	10.0.0.0/16	VPC range
vpc_tags	{}	Custom tags
igw_tags	{}	IGW tags
elastic_ip_tags	{}	EIP tags
nat_gateway_tags	{}	NAT tags
*_subnet_tags	{}	Subnet tags
*_route-tags	{}	Route table tags
vpc_peering_tags	{}	Peering tags
is_peering_required	false	Enable peering
📦 Caller Module Usage
module "VPC" {
  source = "git::https://github.com/viswanadhammanchem13/VPC_Practice.git?ref=main"

  project                = var.project
  environment            = var.environment
  cidr_block             = var.cidr_block
  public_subnet_cidrs    = var.public_subnet_cidrs
  private_subnet_cidrs   = var.private_subnet_cidrs
  database_subnet_cidrs  = var.database_subnet_cidrs
  is_peering_required    = true
}
📌 SSM Parameter Store Integration

Stores outputs for reuse:

resource "aws_ssm_parameter"
Why used:
Centralized config storage
Cross-module usage
Avoid hardcoding values
Example:
VPC ID
Subnet IDs
⚠️ Key Design Decisions (Important for Interviews)
1. Why NAT Gateway?
Private subnets should NOT have direct internet access
NAT provides controlled outbound connectivity
2. Why separate subnets?
Security isolation
Better routing control
Follows AWS best practices
3. Why dynamic AZ selection?
Makes module reusable across regions
4. Why peering?
Enables communication between:
Default VPC
Custom VPC
🚀 Summary

This module provides:

Fully automated VPC setup
Scalable subnet design
Secure networking
Optional cross-VPC communication
Reusable and production-ready architecture

