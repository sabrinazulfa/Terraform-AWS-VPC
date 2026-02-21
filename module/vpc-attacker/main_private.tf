# # EIP for NAT
# resource "aws_eip" "nat_eip" {
#   depends_on = [aws_internet_gateway.internet_gateway]
# }

# # NAT
# resource "aws_nat_gateway" "nat_gateway" {
#   allocation_id = aws_eip.nat_eip.id
#   subnet_id     = element(aws_subnet.public_subnet.*.id, 0)

#   tags = {
#     Name = "${var.name}-Nat-Gateway"
#   }
# }

# # Routing tables to route traffic for Private Subnet
# resource "aws_route_table" "private" {
#   vpc_id = aws_vpc.vpc.id

#   tags = {
#     Name = "${var.name}-Private-Route-Table"
#   }
# }

# # Route for NAT
# resource "aws_route" "private_nat_gateway" {
#   route_table_id         = aws_route_table.private.id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = aws_nat_gateway.nat_gateway.id
# }

# # Route table associations for Private Subnets
# resource "aws_route_table_association" "private" {
#   count          = length(var.private_subnets_cidr_block)
#   subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
#   route_table_id = aws_route_table.private.id
# }