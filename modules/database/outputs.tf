output "db_instance_id" {
  value = module.db[0].db_instance_identifier
}

output "postgres_username" {
  value = var.rds_username
}

output "postgres_password" {
  value = random_password.rds_master_password.result
}

output "postgres_database_name" {
  value = var.database_name
}

output "postgres_host" {
  value = one(module.db[*].db_instance_address) == null ? "not_set" : one(module.db[*].db_instance_address)
}

output "postgres_port" {
  value = one(module.db[*].db_instance_port)
}
