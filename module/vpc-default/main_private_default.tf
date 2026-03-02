# Private Subnet
resource "aws_subnet" "private_subnet_default" {
  vpc_id                  = var.vpc_default_id
  count                   = length(var.private_subnet_defaults_cidr_block)
  cidr_block              = element(var.private_subnet_defaults_cidr_block, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false
  tags                   = {
    Name = "${var.name}-Private-Subnet-${element(var.availability_zones, count.index)}"
  }
}

# EIP for NAT
resource "aws_eip" "nat_eip_default" {
  depends_on = [var.internet_gateway_default]
}

# NAT
resource "aws_nat_gateway" "nat_gateway_default" {
  allocation_id = aws_eip.nat_eip_default.id
  subnet_id     = element(aws_subnet.public_subnet_default.*.id, 0)

  tags = {
    Name = "${var.name}-Nat-Gateway"
  }
}

# Routing tables to route traffic for Private Subnet
resource "aws_route_table" "private_rt_default" {
  vpc_id = var.vpc_default_id

  tags = {
    Name = "${var.name}-Private-Route-Table"
  }
}

# Route for NAT
resource "aws_route" "private_nat_gateway_default" {
  route_table_id         = aws_route_table.private_rt_default.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway_default.id
}

# Route table associations for Private Subnets
resource "aws_route_table_association" "private_default" {
  count          = length(var.private_subnet_defaults_cidr_block)
  subnet_id      = element(aws_subnet.private_subnet_default.*.id, count.index)
  route_table_id = aws_route_table.private_rt_default.id
}