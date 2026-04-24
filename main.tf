resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = merge(
    var.vpc_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-vpc"
    }
  )
}

resource "aws_internet_gateway" "main"{
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.igw_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-igw"
    }
  )
}

resource "aws_eip" "elastic_ip" {
   domain   = "vpc"
   tags = merge(
    var.elastic_ip_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-elastic-ip"
    }
  )
   
}

 #roboshop-dev-public-useast-1a
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = local.Az-info[count.index]
  map_public_ip_on_launch = true  

  tags = merge(
    var.public_subnet_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-public-${local.Az-info[count.index]}"
    }
  )
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = local.Az-info[count.index]

  tags = merge(
    var.private_subnet_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-private-${local.Az-info[count.index]}"
    }
  )
}

resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]
  availability_zone = local.Az-info[count.index]

  tags = merge(
    var.database_subnet_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-database-${local.Az-info[count.index]}"
    }
  )
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.elastic_ip.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.nat_gateway_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-nat-gw"
    }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main] # This ensures that the NAT Gateway is created after the Internet Gateway is available.
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.public_route-tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-public-rt"
    }
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.private_route-tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-private-rt"
    }
  )
}


resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.database_route-tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-database-rt"
    }
  )
}

resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat_gw.id
}

resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat_gw.id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}

