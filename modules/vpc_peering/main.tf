resource "aws_vpc_peering_connection" "private_access" {
  peer_owner_id = var.peer_owner_id
  peer_vpc_id   = var.peer_vpc_id
  peer_region   = var.peer_region
  vpc_id        = var.vpc_id

  tags = {
    Name = "${var.deployment_name}-peer"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route" "main_peering_route" {
  route_table_id            = var.vpc_main_route_table_id
  destination_cidr_block    = var.peer_vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.private_access.id
}

resource "aws_route" "private_peering_route" {
  route_table_id            = var.vpc_private_route_table_id
  destination_cidr_block    = var.peer_vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.private_access.id
}

resource "aws_route" "public_peering_route" {
  route_table_id            = var.vpc_public_route_table_id
  destination_cidr_block    = var.peer_vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.private_access.id
}
