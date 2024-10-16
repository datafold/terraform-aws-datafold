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


resource "aws_route_table" "private_access" {
  vpc_id = var.vpc_id

  route {
    cidr_block = var.peer_vpc_cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.private_access.id
  }

  tags = {
    Name = "${var.deployment_name}-peer-route"
  }
}