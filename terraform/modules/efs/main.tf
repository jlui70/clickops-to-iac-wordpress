# EFS File System
resource "aws_efs_file_system" "wordpress" {
  creation_token = "${var.project_name}-efs"
  encrypted      = false

  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name        = "wordpress-efs"
    Environment = var.environment
  }
}

# Mount Targets (um por AZ)
resource "aws_efs_mount_target" "wordpress" {
  count = length(var.private_subnet_ids)

  file_system_id  = aws_efs_file_system.wordpress.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [var.efs_security_group_id]
}
