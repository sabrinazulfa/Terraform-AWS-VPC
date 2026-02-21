# Public subnet
resource "aws_subnet" "public_subnet_default" {
  vpc_id                  = var.vpc_default_id
  count                   = length(var.public_subnet_defaults_cidr_block)
  cidr_block              = element(var.public_subnet_defaults_cidr_block, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags                    = {
    Name = "${var.name}-Public-Subnet-${element(var.availability_zones, count.index)}"
  }
}

# Internet Gateway for Public Subnet
# resource "aws_internet_gateway" "internet_gateway" {
#   vpc_id = aws_vpc.vpc.id
#   tags   = {
#     Name = "${var.name}-Internet-Gateway"
#   }
# }

# Routing tables to route traffic for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = var.vpc_default_id

  tags = {
    Name = "${var.name}-Public-Route-Table"
  }
}

# Route for Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.internet_gateway_default
}

# Route table associations for Public Subnets
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_defaults_cidr_block)
  subnet_id      = element(aws_subnet.public_subnet_default.*.id, count.index)
  route_table_id = aws_route_table.public.id
}