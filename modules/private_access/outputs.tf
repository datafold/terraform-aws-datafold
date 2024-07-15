output "private_vpces_name" {
  value = aws_vpc_endpoint_service.pl_control_plane.service_name
}

output "private_access_az" {
  value = data.aws_subnet.private_access_az.availability_zone_id
}
