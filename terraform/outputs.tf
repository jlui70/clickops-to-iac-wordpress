output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = try(module.load_balancing.alb_dns_name, null)
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = try(module.database.db_endpoint, null)
  sensitive   = true
}

output "efs_dns_name" {
  description = "EFS DNS name for mounting"
  value       = try(module.efs.efs_dns_name, null)
}

output "wordpress_url" {
  description = "WordPress access URL"
  value       = try("http://${module.load_balancing.alb_dns_name}", "Not deployed yet")
}

output "vpc_id" {
  description = "VPC ID"
  value       = try(module.networking.vpc_id, null)
}
