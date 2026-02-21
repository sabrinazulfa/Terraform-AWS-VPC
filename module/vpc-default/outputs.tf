output "public_subnets_id" {
  value = [aws_subnet.public_subnet_default.*.id]
}

output "private_subnets_id" {
  value = [aws_subnet.private_subnet_default.*.id]
}

output "public_route_table" {
  value = aws_route_table.public.id
}