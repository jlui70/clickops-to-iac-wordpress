output "db_endpoint" {
  description = "Endpoint do RDS"
  value       = aws_db_instance.wordpress.endpoint
}

output "db_address" {
  description = "Endereço do RDS (sem porta)"
  value       = aws_db_instance.wordpress.address
}

output "db_name" {
  description = "Nome do banco de dados"
  value       = aws_db_instance.wordpress.db_name
}

output "db_port" {
  description = "Porta do banco"
  value       = aws_db_instance.wordpress.port
}

output "db_instance_id" {
  description = "ID da instância RDS"
  value       = aws_db_instance.wordpress.id
}
