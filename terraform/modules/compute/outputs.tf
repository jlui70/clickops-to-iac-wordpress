output "launch_template_id" {
  description = "ID do Launch Template"
  value       = aws_launch_template.wordpress.id
}

output "launch_template_latest_version" {
  description = "Última versão do Launch Template"
  value       = aws_launch_template.wordpress.latest_version
}

output "ami_id" {
  description = "ID da AMI utilizada"
  value       = data.aws_ami.amazon_linux_2.id
}
