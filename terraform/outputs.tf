# =============================================================================
# OUTPUTS PRINCIPAIS
# =============================================================================

output "wordpress_url" {
  description = "URL para acessar o WordPress"
  value       = "http://${module.load_balancing.alb_dns_name}"
}

output "alb_dns_name" {
  description = "DNS do Application Load Balancer"
  value       = module.load_balancing.alb_dns_name
}

output "vpc_id" {
  description = "ID da VPC"
  value       = module.networking.vpc_id
}

output "rds_endpoint" {
  description = "Endpoint do RDS"
  value       = module.database.db_endpoint
  sensitive   = true
}

output "efs_dns_name" {
  description = "DNS do EFS"
  value       = module.efs.efs_dns_name
}

output "efs_id" {
  description = "ID do EFS"
  value       = module.efs.efs_id
}

output "asg_name" {
  description = "Nome do Auto Scaling Group"
  value       = module.load_balancing.asg_name
}

output "nat_gateway_ip" {
  description = "IP público do NAT Gateway"
  value       = module.networking.nat_gateway_id
}
