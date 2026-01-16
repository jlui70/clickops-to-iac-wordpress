# 🔧 Exemplo Prático: Módulo Terraform de Networking

## Estrutura do Módulo

```
terraform/modules/networking/
├── main.tf       # Recursos principais
├── variables.tf  # Variáveis de entrada
└── outputs.tf    # Valores de saída
```

---

## 📄 variables.tf

```hcl
# terraform/modules/networking/variables.tf

variable "project_name" {
  description = "Nome do projeto para tags e nomenclatura"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block para a VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Lista de AZs para usar"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks para subnets públicas"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks para subnets privadas"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "enable_nat_gateway" {
  description = "Criar NAT Gateway para subnets privadas"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags adicionais para recursos"
  type        = map(string)
  default     = {}
}
```

---

## 📄 main.tf

```hcl
# terraform/modules/networking/main.tf

# ============================================================================
# VPC
# ============================================================================

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    {
      Name        = "${var.project_name}-vpc"
      Environment = var.environment
    },
    var.tags
  )
}

# ============================================================================
# Internet Gateway
# ============================================================================

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name        = "${var.project_name}-igw"
      Environment = var.environment
    },
    var.tags
  )
}

# ============================================================================
# Subnets Públicas
# ============================================================================

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name        = "${var.project_name}-public-subnet-${count.index + 1}"
      Environment = var.environment
      Type        = "Public"
      AZ          = var.availability_zones[count.index]
    },
    var.tags
  )
}

# ============================================================================
# Subnets Privadas
# ============================================================================

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name        = "${var.project_name}-private-subnet-${count.index + 1}"
      Environment = var.environment
      Type        = "Private"
      AZ          = var.availability_zones[count.index]
    },
    var.tags
  )
}

# ============================================================================
# Elastic IP para NAT Gateway
# ============================================================================

resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? 1 : 0

  domain = "vpc"

  tags = merge(
    {
      Name        = "${var.project_name}-nat-eip"
      Environment = var.environment
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.main]
}

# ============================================================================
# NAT Gateway
# ============================================================================

resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    {
      Name        = "${var.project_name}-nat-gateway"
      Environment = var.environment
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.main]
}

# ============================================================================
# Route Table Pública
# ============================================================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name        = "${var.project_name}-public-rt"
      Environment = var.environment
      Type        = "Public"
    },
    var.tags
  )
}

# Rota para Internet via IGW
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Associar subnets públicas à route table pública
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ============================================================================
# Route Tables Privadas
# ============================================================================

resource "aws_route_table" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name        = "${var.project_name}-private-rt-${count.index + 1}"
      Environment = var.environment
      Type        = "Private"
      AZ          = var.availability_zones[count.index]
    },
    var.tags
  )
}

# Rota para Internet via NAT Gateway (se habilitado)
resource "aws_route" "private_internet" {
  count = var.enable_nat_gateway ? length(var.private_subnet_cidrs) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[0].id
}

# Associar subnets privadas às suas route tables
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# ============================================================================
# VPC Flow Logs (Opcional - Boas Práticas)
# ============================================================================

# CloudWatch Log Group para VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/${var.project_name}-flow-logs"
  retention_in_days = 7

  tags = merge(
    {
      Name        = "${var.project_name}-vpc-flow-logs"
      Environment = var.environment
    },
    var.tags
  )
}

# IAM Role para VPC Flow Logs
resource "aws_iam_role" "vpc_flow_logs" {
  name = "${var.project_name}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    {
      Name        = "${var.project_name}-vpc-flow-logs-role"
      Environment = var.environment
    },
    var.tags
  )
}

# IAM Policy para VPC Flow Logs
resource "aws_iam_role_policy" "vpc_flow_logs" {
  name = "${var.project_name}-vpc-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}

# VPC Flow Logs
resource "aws_flow_log" "main" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id

  tags = merge(
    {
      Name        = "${var.project_name}-vpc-flow-logs"
      Environment = var.environment
    },
    var.tags
  )
}
```

---

## 📄 outputs.tf

```hcl
# terraform/modules/networking/outputs.tf

# ============================================================================
# VPC Outputs
# ============================================================================

output "vpc_id" {
  description = "ID da VPC criada"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block da VPC"
  value       = aws_vpc.main.cidr_block
}

output "vpc_arn" {
  description = "ARN da VPC"
  value       = aws_vpc.main.arn
}

# ============================================================================
# Internet Gateway Outputs
# ============================================================================

output "internet_gateway_id" {
  description = "ID do Internet Gateway"
  value       = aws_internet_gateway.main.id
}

# ============================================================================
# Subnets Públicas Outputs
# ============================================================================

output "public_subnet_ids" {
  description = "Lista de IDs das subnets públicas"
  value       = aws_subnet.public[*].id
}

output "public_subnet_cidrs" {
  description = "Lista de CIDRs das subnets públicas"
  value       = aws_subnet.public[*].cidr_block
}

output "public_subnet_azs" {
  description = "Lista de AZs das subnets públicas"
  value       = aws_subnet.public[*].availability_zone
}

# ============================================================================
# Subnets Privadas Outputs
# ============================================================================

output "private_subnet_ids" {
  description = "Lista de IDs das subnets privadas"
  value       = aws_subnet.private[*].id
}

output "private_subnet_cidrs" {
  description = "Lista de CIDRs das subnets privadas"
  value       = aws_subnet.private[*].cidr_block
}

output "private_subnet_azs" {
  description = "Lista de AZs das subnets privadas"
  value       = aws_subnet.private[*].availability_zone
}

# ============================================================================
# NAT Gateway Outputs
# ============================================================================

output "nat_gateway_id" {
  description = "ID do NAT Gateway (se habilitado)"
  value       = var.enable_nat_gateway ? aws_nat_gateway.main[0].id : null
}

output "nat_gateway_public_ip" {
  description = "IP público do NAT Gateway (se habilitado)"
  value       = var.enable_nat_gateway ? aws_eip.nat[0].public_ip : null
}

# ============================================================================
# Route Tables Outputs
# ============================================================================

output "public_route_table_id" {
  description = "ID da route table pública"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "Lista de IDs das route tables privadas"
  value       = aws_route_table.private[*].id
}

# ============================================================================
# Availability Zones Outputs
# ============================================================================

output "availability_zones" {
  description = "Lista de AZs utilizadas"
  value       = var.availability_zones
}
```

---

## 🔄 Como Usar Este Módulo

### No main.tf principal

```hcl
# terraform/main.tf

module "networking" {
  source = "./modules/networking"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = ["us-east-1a", "us-east-1b"]
  
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
  
  enable_nat_gateway = true

  tags = {
    Terraform   = "true"
    Owner       = "DevOps Team"
    CostCenter  = "Engineering"
  }
}

# Usar outputs do módulo em outros módulos
module "security_groups" {
  source = "./modules/security-groups"
  
  vpc_id = module.networking.vpc_id
  # ...
}

module "database" {
  source = "./modules/database"
  
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  # ...
}
```

---

## 🧪 Testar o Módulo

```bash
# 1. Inicializar
cd terraform
terraform init

# 2. Validar sintaxe
terraform validate

# 3. Formatar código
terraform fmt -recursive

# 4. Ver plano
terraform plan

# 5. Ver apenas o módulo de networking
terraform plan -target=module.networking

# 6. Aplicar apenas networking (para testar)
terraform apply -target=module.networking

# 7. Ver outputs
terraform output

# 8. Ver output específico
terraform output -module=networking vpc_id

# 9. Ver grafo de dependências
terraform graph | dot -Tpng > graph.png

# 10. Destruir quando não precisar
terraform destroy
```

---

## 📊 Comparação: ClickOps vs Terraform para Networking

### ClickOps (Manual)
```
1. Abrir AWS Console
2. Navegar para VPC
3. Clicar em "Create VPC"
4. Selecionar "VPC and more"
5. Preencher nome: wp-docker
6. Preencher CIDR: 10.0.0.0/16
7. Selecionar 2 AZs
8. Selecionar 2 subnets públicas
9. Selecionar 2 subnets privadas
10. NAT Gateway: None (manual)
11. Clicar em "Create VPC"
12. Aguardar criação (2-3 min)
13. Ir para NAT Gateways
14. Clicar em "Create NAT Gateway"
15. Preencher nome
16. Selecionar subnet pública
17. Clicar em "Allocate Elastic IP"
18. Confirmar e criar
19. Aguardar criação (3-5 min)
20. Ir para Route Tables
21. Identificar RT privadas (2)
22. Para cada RT privada:
    23. Selecionar RT
    24. Clicar em "Edit routes"
    25. Clicar em "Add route"
    26. Destination: 0.0.0.0/0
    27. Target: NAT Gateway (selecionar)
    28. Salvar
29. Verificar tudo manualmente

TEMPO TOTAL: ~15-20 minutos
CLIQUES: ~50-60
POSSIBILIDADE DE ERRO: Alta
```

### Terraform (Código)
```bash
# 1. Escrever código (já mostrado acima)
# 2. terraform init
# 3. terraform apply -auto-approve

TEMPO ESCRITA INICIAL: ~1-2 horas (mas reutilizável!)
TEMPO DE EXECUÇÃO: ~8-10 minutos
TEMPO DE REPLICAÇÃO: ~5 minutos
CLIQUES: 0
POSSIBILIDADE DE ERRO: Muito Baixa
```

---

## ✅ Benefícios do Módulo Terraform

### 1. Reutilização
```hcl
# Ambiente Dev
module "networking_dev" {
  source = "./modules/networking"
  environment = "dev"
  vpc_cidr = "10.0.0.0/16"
}

# Ambiente Prod (idêntico!)
module "networking_prod" {
  source = "./modules/networking"
  environment = "prod"
  vpc_cidr = "10.1.0.0/16"
}
```

### 2. Versionamento
```bash
git log modules/networking/main.tf
# Ver histórico completo de mudanças
```

### 3. Documentação
O código É a documentação! Sempre atualizada.

### 4. Validação
```bash
terraform validate  # Valida sintaxe
terraform plan      # Valida configuração
```

### 5. Rollback
```bash
git revert HEAD
terraform apply  # Volta para versão anterior
```

### 6. Testes
```hcl
# Pode criar testes automatizados
# Usando Terratest, Kitchen-Terraform, etc.
```

---

## 🎯 Próximos Passos

1. ✅ **Entendeu o módulo de networking**
2. ⬜ Criar módulo de security-groups
3. ⬜ Criar módulo de database
4. ⬜ Criar módulo de efs
5. ⬜ Criar módulo de iam
6. ⬜ Criar módulo de compute
7. ⬜ Criar módulo de load-balancing
8. ⬜ Integrar todos os módulos
9. ⬜ Testar e validar
10. ⬜ Documentar e comparar

---

## 📚 Recursos Adicionais

### Documentação Oficial
- [Terraform AWS Provider - VPC](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)
- [AWS VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-best-practices.html)

### Exemplos
- [Terraform AWS Modules - VPC](https://github.com/terraform-aws-modules/terraform-aws-vpc)

### Ferramentas
```bash
# Verificar custos estimados
infracost breakdown --path .

# Lint do código
tflint

# Verificar segurança
checkov -d .

# Gerar documentação
terraform-docs markdown . > README.md
```

---

## 🚀 Conclusão

Este módulo de networking demonstra:

✅ **Organização**: Código bem estruturado e modular
✅ **Reutilização**: Pode ser usado em múltiplos projetos
✅ **Documentação**: Comentários e outputs claros
✅ **Boas Práticas**: Tags, naming conventions, flow logs
✅ **Flexibilidade**: Variáveis para customização
✅ **Manutenibilidade**: Fácil de entender e modificar

**vs ClickOps**: ~50 cliques e 20 minutos toda vez!

Este é apenas **1 dos 7 módulos** necessários. Imagine a economia de tempo e esforço multiplicada por todos os módulos! 🎉

---

**Quer implementar este módulo agora?** Execute os comandos do "Setup Inicial" no [GUIA-RAPIDO.md](GUIA-RAPIDO.md)!
