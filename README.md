📘 Terraform AWS VPC Module
📌 Overview

This module creates a complete AWS VPC infrastructure using Terraform with:

VPC
Public, Private, Database Subnets
Internet Gateway (IGW)
NAT Gateway with Elastic IP
Route Tables & Associations
Optional VPC Peering
SSM Parameter Store integration
🧱 Architecture Diagram (Explanation with Comments)
## 1. VPC Peering (Optional)
Enables communication between Default VPC and Custom VPC
Controlled using:
is_peering_required = true
Adds routes in all route tables (public, private, database, default)
## 2. Multi-AZ Subnet Design
Subnets are created dynamically across AZs:
locals {
  Az-info = slice(data.aws_availability_zones.available.names, 0, 2)
}
Improves:
High Availability
Fault Tolerance
## 3. Public Subnets (Internet Access)
Connected to Internet Gateway
Route:
0.0.0.0/0 → IGW
Key setting:
map_public_ip_on_launch = true
Used for:
Bastion Host
Load Balancer
Public EC2
## 4. Private & Database Subnets (Secure Access)
No direct internet access
Use NAT Gateway for outbound traffic
Route:
0.0.0.0/0 → NAT Gateway
Why NAT?
Secure outbound access
No inbound exposure
## 5. NAT Gateway + Elastic IP
NAT Gateway placed in public subnet
Uses:
allocation_id = aws_eip.elastic_ip.id
Purpose:
Private subnet internet access
Static IP via Elastic IP
## 6. Internet Gateway (IGW)
Attached to VPC:
vpc_id = aws_vpc.main.id
Enables:
Public subnet internet access
## 7. Route Tables
Public Route Table
0.0.0.0/0 → IGW
Private Route Table
0.0.0.0/0 → NAT Gateway
Database Route Table
0.0.0.0/0 → NAT Gateway
## 8. SSM Parameter Store (Outputs)
Stores values for reuse:
/aws/project/env/vpc-id
/aws/project/env/public-subnet
Benefits:
Centralized config
Reusable across modules
No hardcoding
⚙️ Resources Breakdown
## VPC
Creates isolated network
Required:
cidr_block
Optional:
instance_tenancy
enable_dns_hostnames
## Subnets
Public Subnets
Internet accessible
Private Subnets
Internal services
Database Subnets
Highly secure
Required:
cidr_block
availability_zone
## NAT Gateway
Required:
Elastic IP
Public subnet
Important:
depends_on = [aws_internet_gateway.main]
## Route Tables
Control traffic flow
Required:
vpc_id
## VPC Peering
Optional Feature
Enabled via:
is_peering_required = true
📥 Input Variables
## Required Variables
Variable	Description
project	    Project name
environment	Environment name
public_subnet_cidrs	Public subnet ranges
private_subnet_cidrs	Private subnet ranges
database_subnet_cidrs	Database subnet ranges
## Optional Variables
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
📤 Outputs
Output	Description
vpc-id	VPC ID
public-subnet	Public subnet IDs
private-subnet	Private subnet IDs
database-subnet	Database subnet IDs
default_vpc	Default VPC ID
default_route_table	Default route table
🚀 Execution Flow (Step-by-Step)
## Step 1

Create VPC

## Step 2

Create Internet Gateway

## Step 3

Create Subnets (Public, Private, Database)

## Step 4

Create Elastic IP

## Step 5

Create NAT Gateway

## Step 6

Create Route Tables

## Step 7

Associate Subnets with Route Tables

## Step 8 (Optional)

Create VPC Peering

## Step 9

Store Outputs in SSM

⚠️ Key Interview Points
## Why NAT Gateway?
Private subnet should not have direct internet access
## Why separate subnets?
Security isolation
Layered architecture
## Why AZ slicing?
Avoid hardcoding
Multi-region support
## Why SSM Parameter Store?
Centralized config
Cross-module sharing
📌 Summary
Production-ready VPC setup
Secure architecture (no direct private access)
Highly reusable Terraform module
Supports peering and multi-AZ design