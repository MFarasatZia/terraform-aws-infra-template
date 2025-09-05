resource "aws_route" "nat_instance_route" {
  count                  = length(module.vpc.private_route_table_ids)
  route_table_id         = element(module.vpc.private_route_table_ids, count.index)
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat_instance.primary_network_interface_id
}
