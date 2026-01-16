# 🚀 Guia Rápido de Implementação

## Checklist de Ação Imediata

### ✅ Fase Preparação

#### 1. Setup Inicial do Projeto
```bash
# 1. Criar novo diretório do projeto
cd ~/Projects
mkdir projeto-wordpress-clickops-vs-iac
cd projeto-wordpress-clickops-vs-iac

# 2. Inicializar Git
git init
echo "# WordPress: ClickOps vs IaC (Terraform)" > README.md

# 3. Criar estrutura de pastas
mkdir -p clickops/{Img,docs}
mkdir -p terraform/{modules,environments/{dev,prod},scripts}
mkdir -p terraform/modules/{networking,security-groups,database,efs,iam,compute,load-balancing}
mkdir -p docs
mkdir -p tests
mkdir -p ansible/vars

# 4. Criar .gitignore
cat > .gitignore << 'EOF'
# Terraform
**/.terraform/*
*.tfstate
*.tfstate.*
*.tfvars
!terraform.tfvars.example
crash.log
override.tf
override.tf.json
*_override.tf
*_override.tf.json
.terraformrc
terraform.rc

# AWS
.aws/
*.pem
*.key

# Secrets
secrets/
*.secret
.env

# OS
.DS_Store
Thumbs.db

# IDEs
.vscode/
.idea/
*.swp
*.swo
*~

# Logs
*.log
EOF

# 5. Copiar projeto atual para referência
cp -r ../projeto-docker-ansible-wordpress-aws/README.md clickops/
cp -r ../projeto-docker-ansible-wordpress-aws/Img clickops/ 2>/dev/null || true
cp ../projeto-docker-ansible-wordpress-aws/playbook.yml ansible/
cp ../projeto-docker-ansible-wordpress-aws/vars/repos.yml ansible/vars/ 2>/dev/null || true
```

#### 2. Configurar Ferramentas

```bash
# Verificar instalações necessárias
terraform version  # Deve ser >= 1.0
aws --version      # AWS CLI v2
docker --version
git --version

# Se precisar instalar Terraform (Ubuntu/Debian)
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Configurar AWS CLI (se ainda não configurado)
aws configure
# Inserir: AWS Access Key ID, Secret Access Key, região (ex: us-east-1)
```

#### 3. Criar Arquivos Base do Terraform

```bash
cd terraform

# versions.tf
cat > versions.tf << 'EOF'
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "WordPress-ClickOps-vs-IaC"
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}
EOF

# variables.tf
cat > variables.tf << 'EOF'
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "wp-docker"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "wordpressdb"
}
EOF

# terraform.tfvars.example
cat > terraform.tfvars.example << 'EOF'
aws_region   = "us-east-1"
environment  = "dev"
project_name = "wp-docker"
vpc_cidr     = "10.0.0.0/16"

# Database credentials (CHANGE THESE!)
db_username = "admin"
db_password = "CHANGE_ME_STRONG_PASSWORD"
db_name     = "wordpressdb"
EOF

# outputs.tf
cat > outputs.tf << 'EOF'
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.load_balancing.alb_dns_name
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.database.db_endpoint
  sensitive   = true
}

output "efs_dns_name" {
  description = "EFS DNS name for mounting"
  value       = module.efs.efs_dns_name
}

output "wordpress_url" {
  description = "WordPress access URL"
  value       = "http://${module.load_balancing.alb_dns_name}"
}
EOF
```

---

## 📋 Checklist de Implementação ClickOps

### Antes de Começar
- [ ] Conta AWS criada e configurada
- [ ] Billing alerts configurados
- [ ] MFA ativado
- [ ] Região selecionada (ex: us-east-1)
- [ ] Cronômetro preparado ⏱️

### Implementação (Seguir README do projeto atual)
- [ ] **START TIMER** ⏱️
- [ ] Parte 1: VPC (estimar ~15-20 min)
- [ ] Parte 2: Security Groups (estimar ~20-25 min)
- [ ] Parte 3: IAM Role SSM (estimar ~5 min)
- [ ] Parte 4: RDS (estimar ~10 min + 15 min criação)
- [ ] Parte 5: EFS (estimar ~10 min)
- [ ] Parte 6: Launch Template (estimar ~15-20 min)
- [ ] Parte 7: Load Balancer (estimar ~10 min)
- [ ] Parte 8: Auto Scaling Group (estimar ~10 min)
- [ ] Parte 9: Testes (estimar ~10-15 min)
- [ ] **STOP TIMER** ⏱️

### Documentação
- [ ] Anotar tempo total
- [ ] Anotar dificuldades encontradas
- [ ] Screenshots de cada etapa
- [ ] Erros cometidos e como corrigiu
- [ ] Salvar em `clickops/METRICAS-CLICKOPS.md`

### Limpeza
- [ ] Testar funcionalidade completa
- [ ] Documentar processo de destruição
- [ ] Destruir recursos (ordem inversa!)
- [ ] Verificar custos incorridos

---

## 🏗️ Checklist de Implementação Terraform

### Módulo 1: Networking
```bash
cd terraform/modules/networking
```

- [ ] Criar `main.tf` com:
  - [ ] VPC
  - [ ] Internet Gateway
  - [ ] Subnets públicas (2 AZs)
  - [ ] Subnets privadas (2 AZs)
  - [ ] Elastic IP para NAT
  - [ ] NAT Gateway
  - [ ] Route Tables (pública e privadas)
  - [ ] Route Table Associations
- [ ] Criar `variables.tf`
- [ ] Criar `outputs.tf`
- [ ] Testar: `terraform init && terraform plan`

### Módulo 2: Security Groups
```bash
cd terraform/modules/security-groups
```

- [ ] Criar `main.tf` com 4 SGs:
  - [ ] ALB-SG
  - [ ] App-SG
  - [ ] DB-SG
  - [ ] EFS-SG
- [ ] Criar `variables.tf`
- [ ] Criar `outputs.tf`

### Módulo 3: IAM
```bash
cd terraform/modules/iam
```

- [ ] Criar `main.tf` com:
  - [ ] IAM Role para EC2
  - [ ] IAM Instance Profile
  - [ ] Policy attachment (SSM)
- [ ] Criar `variables.tf`
- [ ] Criar `outputs.tf`

### Módulo 4: Database (RDS)
```bash
cd terraform/modules/database
```

- [ ] Criar `main.tf` com:
  - [ ] DB Subnet Group
  - [ ] RDS MySQL Instance
  - [ ] Parameter Group (opcional)
- [ ] Criar `variables.tf`
- [ ] Criar `outputs.tf`

### Módulo 5: EFS
```bash
cd terraform/modules/efs
```

- [ ] Criar `main.tf` com:
  - [ ] EFS File System
  - [ ] Mount Targets (2 AZs)
- [ ] Criar `variables.tf`
- [ ] Criar `outputs.tf`

### Módulo 6: Compute
```bash
cd terraform/modules/compute
```

- [ ] Criar `user-data.sh` (script separado)
- [ ] Criar `main.tf` com:
  - [ ] Launch Template
  - [ ] Template_file para user-data
- [ ] Criar `variables.tf`
- [ ] Criar `outputs.tf`

### Módulo 7: Load Balancing
```bash
cd terraform/modules/load-balancing
```

- [ ] Criar `main.tf` com:
  - [ ] Target Group
  - [ ] Application Load Balancer
  - [ ] ALB Listener
  - [ ] Auto Scaling Group
  - [ ] ASG Attachment
- [ ] Criar `variables.tf`
- [ ] Criar `outputs.tf`

### Integração Final
```bash
cd terraform
```

- [ ] Criar `main.tf` principal chamando todos os módulos
- [ ] Configurar dependências entre módulos
- [ ] Criar `terraform.tfvars` (copiar do .example)
- [ ] Executar `terraform init`
- [ ] Executar `terraform validate`
- [ ] Executar `terraform plan`
- [ ] **START TIMER** ⏱️
- [ ] Executar `terraform apply`
- [ ] **STOP TIMER** ⏱️
- [ ] Aguardar criação (~10-15 min)

### Testes
- [ ] Verificar outputs
- [ ] Acessar ALB DNS
- [ ] Configurar WordPress
- [ ] Testar persistência (EFS)
- [ ] Testar escalabilidade (ASG)
- [ ] Acessar instâncias via SSM

### Limpeza
- [ ] Documentar estado final
- [ ] **START TIMER** ⏱️
- [ ] `terraform destroy`
- [ ] **STOP TIMER** ⏱️
- [ ] Verificar recursos deletados

---

## 📊 Template de Coleta de Métricas

Criar arquivo `METRICAS.md`:

```markdown
# Métricas Coletadas

## ClickOps
- **Tempo total de implementação**: ___ minutos
- **Número de passos manuais**: ~80-100
- **Número de cliques estimado**: ~300-400
- **Erros cometidos**: ___
- **Tempo para corrigir erros**: ___ minutos
- **Tempo para destruir**: ___ minutos
- **Dificuldade (1-10)**: ___
- **Possibilidade de erro humano**: Alta

## Terraform
- **Tempo para escrever código**: ___ minutos
- **Linhas de código**: ___
- **Tempo de execução (apply)**: ___ minutos
- **Tempo de destruição (destroy)**: ___ minutos
- **Número de recursos gerenciados**: ___
- **Erros durante apply**: ___
- **Tempo para corrigir erros**: ___ minutos
- **Dificuldade (1-10)**: ___
- **Possibilidade de erro humano**: Baixa

## Comparação
- **Reprodutibilidade**: ClickOps ❌ | Terraform ✅
- **Versionamento**: ClickOps ❌ | Terraform ✅
- **Documentação**: ClickOps Manual | Terraform Automática
- **Rollback**: ClickOps Difícil | Terraform Fácil
- **Manutenção**: ClickOps Complexa | Terraform Simples
```

---

## 🎯 Ordem Recomendada de Execução

### Semana 1: Preparação e ClickOps
1. **Dia 1**: Setup do projeto + documentação
2. **Dia 2**: Implementação ClickOps completa
3. **Dia 3**: Testes ClickOps + documentação de métricas

### Semana 2: Terraform Base
4. **Dia 4**: Módulos Networking + Security Groups
5. **Dia 5**: Módulos IAM + Database
6. **Dia 6**: Módulos EFS + Compute

### Semana 3: Terraform Completo
7. **Dia 7**: Módulo Load Balancing + integração
8. **Dia 8**: Testes e validação
9. **Dia 9**: Refinamento e correções

### Semana 4: Documentação Final
10. **Dia 10**: Documentação comparativa
11. **Dia 11**: Diagramas e apresentação
12. **Dia 12**: Revisão final e publicação

---

## 💰 Controle de Custos

### Configurar Billing Alert (IMPORTANTE!)
```bash
# Via AWS Console:
# 1. Ir para AWS Billing Dashboard
# 2. Preferences > Billing alerts > Edit
# 3. Criar alerta para $10, $20, $50
```

### Recursos que Geram Custo
- ❗ **NAT Gateway**: $0.045/hora = ~$32/mês (MAIOR CUSTO)
- ❗ **ALB**: $0.0225/hora = ~$16/mês
- ✅ **EC2 t2.micro**: Free Tier (750h/mês)
- ✅ **RDS db.t3.micro**: Free Tier (750h/mês)
- ⚠️ **EFS**: $0.30/GB-mês (mínimo)
- ⚠️ **Data Transfer**: Cuidado com tráfego

### Dicas para Economizar
1. **Destrua quando não usar!** 
   ```bash
   terraform destroy -auto-approve
   ```
2. **Use horário comercial**: Crie de manhã, destrua à noite
3. **Considere NAT Instance**: Mais barato que NAT Gateway
4. **Desabilite backups**: Economiza storage
5. **Use spot instances**: Para testes (não para este projeto)

---

## 🐛 Troubleshooting Comum

### Terraform

**Erro: No valid credential sources**
```bash
aws configure
# Ou export AWS_ACCESS_KEY_ID e AWS_SECRET_ACCESS_KEY
```

**Erro: Region not set**
```bash
export AWS_DEFAULT_REGION=us-east-1
# Ou configurar em terraform.tfvars
```

**Erro: State lock**
```bash
# Se travar, forçar unlock (cuidado!)
terraform force-unlock <LOCK_ID>
```

**Erro: Resource already exists**
```bash
# Importar recurso existente
terraform import aws_vpc.main vpc-xxxxx
```

### AWS

**EC2 não inicia**
- Verificar User Data script
- Verificar IAM Role
- Verificar Security Group
- Ver logs em CloudWatch

**WordPress não carrega**
- Verificar Target Group health
- Verificar Security Groups
- Verificar RDS connectivity
- Verificar EFS mount

**Custo alto inesperado**
- Verificar NAT Gateway
- Verificar ALB
- Verificar Data Transfer
- Destruir recursos não usados

---

## 📚 Recursos Úteis

### Documentação
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Well-Architected](https://aws.amazon.com/architecture/well-architected/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

### Ferramentas
- [Terraform Graph](https://developer.hashicorp.com/terraform/cli/commands/graph): Visualizar dependências
- [Infracost](https://www.infracost.io/): Estimar custos
- [tflint](https://github.com/terraform-linters/tflint): Linter para Terraform
- [terraform-docs](https://terraform-docs.io/): Gerar documentação

### Comandos Úteis
```bash
# Validar sintaxe
terraform validate

# Formatar código
terraform fmt -recursive

# Ver estado atual
terraform show

# Listar recursos
terraform state list

# Ver plano salvo
terraform show tfplan

# Output específico
terraform output alb_dns_name

# Refresh state
terraform refresh

# Visualizar graph
terraform graph | dot -Tpng > graph.png
```

---

## ✅ Checklist Final de Qualidade

### Código
- [ ] Terraform validado sem erros
- [ ] Código formatado (`terraform fmt`)
- [ ] Comentários adequados
- [ ] Variáveis documentadas
- [ ] Outputs úteis definidos
- [ ] Secrets não commitados

### Documentação
- [ ] README principal completo
- [ ] COMPARACAO.md escrito
- [ ] METRICAS.md preenchido
- [ ] Diagramas criados
- [ ] Screenshots incluídos
- [ ] Comandos testados

### Funcionalidade
- [ ] WordPress acessível
- [ ] Auto scaling funciona
- [ ] Persistência (EFS) testada
- [ ] Load balancer distribui
- [ ] SSM acesso funciona
- [ ] Database conecta

### Limpeza
- [ ] Recursos destruídos
- [ ] Custos verificados
- [ ] Git commit feito
- [ ] Backup de estado feito

---

## 🎉 Pronto para Começar!

**Próximo passo**: Execute os comandos da seção "Setup Inicial do Projeto" e comece a implementação!

**Lembre-se**: 
- ⏱️ Cronometrar tudo
- 📝 Documentar tudo
- 💰 Controlar custos
- 🧪 Testar tudo

**Boa sorte!** 🚀
