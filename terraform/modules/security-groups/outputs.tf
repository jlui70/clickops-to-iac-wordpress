output "alb_sg_id" {
  description = "ID do Security Group do ALB"
  value       = aws_security_group.alb.id
}

output "app_sg_id" {
  description = "ID do Security Group da aplicação"
  value       = aws_security_group.app.id
}

output "db_sg_id" {
  description = "ID do Security Group do banco"
  value       = aws_security_group.db.id
}

output "efs_sg_id" {
  description = "ID do Security Group do EFS"
  value       = aws_security_group.efs.id
}
