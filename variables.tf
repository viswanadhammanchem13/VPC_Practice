variable "cidr_block" {
    default = "10.0.0.0/16"
}

variable "vpc_tags" {
  
  type = map(string)
  default = {}
}

variable "igw_tags" {
  
  type = map(string)
  default = {}
}

variable "project" {
    type = string
    default = "roboshop"
}

variable "environment" {
    type = string
    default = "dev"
}

variable "public_subnet_cidrs" {
    type = list(string)
    default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
    type = list(string)
    default = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "database_subnet_cidrs" {
    type = list(string)
    default = ["10.0.21.0/24", "10.0.22.0/24"]
}

variable "public_subnet_tags" { 
  type = map(string)
  default = {}
  
}

variable "private_subnet_tags" { 
  type = map(string)
  default = {}
}

variable "database_subnet_tags" { 
  type = map(string)
  default = {}
  
}

variable "nat_gateway_tags" { 
  type = map(string)
  default = {}
  
}

variable "public_route-tags" {
    type = map(string)
    default = {}
  
}

variable "private_route-tags" {
    type = map(string)
    default = {}
  
}

variable "database_route-tags" {
    type = map(string)
    default = {}
  
}

variable "elastic_ip_tags" {
    type = map(string)
    default = {}
  
}

variable "is_peering_required" {

default = true
  
}

variable "vpc_peering_tags" {
    type = map(string)
    default = {}
  
}