output "subnet" {
    value = aws_subnet.dev-subnet-1
}

output "route_table_id" {
  value = aws_route_table.dev-rtb.id
}
