# Creating Internet Gateway to be attached with Pulic Subnet

# Steps --> 1. Create Internet Gateway
#           2. Create Route Table along with Route to Internet Gateway
#           3. Associate Route Table with Public Subnet

resource "aws_internet_gateway" "this" {
  vpc_id = var.vpc_id

  tags = {
    Name = "Demo Internet Gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = var.public_subnet_ids
  subnet_id      = each.value
  route_table_id = aws_route_table.public.id
}


# Creating NAT Gateway to be attached with Private Subnet

# Steps --> 1. Create Elastic IP
#           2. Create NAT Gateway in Public Subnet
#           3. Create Route Table along with Route to NAT Gateway



resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "Demo NAT EIP"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = var.nat_subnet_id

  depends_on = [
    aws_internet_gateway.this
  ]

  tags = {
    Name = "3-tier-nat-gateway"
  }
}

resource "aws_route_table" "private_app" {
  vpc_id = var.vpc_id

  tags = {
    Name = "Private Route Table"
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }
}

resource "aws_route_table_association" "private" {
  for_each       = var.private_subnet_app_ids
  subnet_id      = each.value
  route_table_id = aws_route_table.private_app.id
}

# Creating Route Table for Private DB Subnets

# Steps --> 1. Create Route Table for Private DB Subnets
#           2. Associate Route Table with Private DB Subnets

resource "aws_route_table" "private_db" {
  vpc_id = var.vpc_id

  tags = {
    Name = "Private DB Route Table"
  }

  
}

resource "aws_route_table_association" "private_db" {
  for_each       = var.private_subnet_db_ids
  subnet_id      = each.value
  route_table_id = aws_route_table.private_db.id
}