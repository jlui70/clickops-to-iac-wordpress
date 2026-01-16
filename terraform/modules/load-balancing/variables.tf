variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs das subnets públicas (para ALB)"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "IDs das subnets privadas (para ASG)"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ID do Security Group do ALB"
  type        = string
}

variable "launch_template_id" {
  description = "ID do Launch Template"
  type        = string
}

variable "launch_template_version" {
  description = "Versão do Launch Template"
  type        = string
}
