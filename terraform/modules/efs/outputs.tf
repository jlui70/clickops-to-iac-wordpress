output "efs_id" {
  description = "ID do EFS"
  value       = aws_efs_file_system.wordpress.id
}

output "efs_dns_name" {
  description = "DNS do EFS para montagem"
  value       = aws_efs_file_system.wordpress.dns_name
}

output "efs_arn" {
  description = "ARN do EFS"
  value       = aws_efs_file_system.wordpress.arn
}

output "mount_target_ids" {
  description = "IDs dos mount targets"
  value       = aws_efs_mount_target.wordpress[*].id
}
