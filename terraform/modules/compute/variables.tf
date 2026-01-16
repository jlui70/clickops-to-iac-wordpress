variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente"
  type        = string
}

variable "app_security_group_id" {
  description = "ID do Security Group da aplicação"
  type        = string
}

variable "instance_profile_name" {
  description = "Nome do Instance Profile IAM"
  type        = string
}

variable "efs_dns_name" {
  description = "DNS do EFS"
  type        = string
}

variable "db_endpoint" {
  description = "Endpoint do RDS"
  type        = string
}

variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
}

variable "db_username" {
  description = "Usuário do banco"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Senha do banco"
  type        = string
  sensitive   = true
}
