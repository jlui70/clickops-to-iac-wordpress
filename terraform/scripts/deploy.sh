#!/bin/bash

# =============================================================================
# Script de Deploy Automatizado - WordPress na AWS com Terraform
# =============================================================================

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  WordPress Infrastructure Deployment - Terraform Automation   ║${NC}"
echo -e "${BLUE}║                   ClickOps vs IaC Demo                         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Verificar se estamos no diretório correto
if [ ! -f "versions.tf" ]; then
    echo -e "${RED}❌ Erro: Execute este script do diretório terraform/${NC}"
    exit 1
fi

# Verificar se terraform.tfvars existe
if [ ! -f "terraform.tfvars" ]; then
    echo -e "${YELLOW}⚠️  terraform.tfvars não encontrado. Criando a partir do exemplo...${NC}"
    cp terraform.tfvars.example terraform.tfvars
    echo -e "${YELLOW}⚠️  IMPORTANTE: Edite terraform.tfvars com suas credenciais antes de continuar!${NC}"
    echo -e "${YELLOW}⚠️  Pressione ENTER para continuar ou CTRL+C para cancelar...${NC}"
    read
fi

# Função para mostrar progresso
show_progress() {
    echo ""
    echo -e "${GREEN}▶ $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Função para mostrar sucesso
show_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Função para mostrar erro
show_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Início do cronômetro
START_TIME=$(date +%s)

# Etapa 1: Inicializar Terraform
show_progress "ETAPA 1/6: Inicializando Terraform"
terraform init
show_success "Terraform inicializado com sucesso!"

# Etapa 2: Validar configuração
show_progress "ETAPA 2/6: Validando configuração"
terraform validate
show_success "Configuração validada!"

# Etapa 3: Formatar código
show_progress "ETAPA 3/6: Formatando código"
terraform fmt -recursive
show_success "Código formatado!"

# Etapa 4: Planejar infraestrutura
show_progress "ETAPA 4/6: Planejando infraestrutura"
echo -e "${YELLOW}Isso pode levar alguns segundos...${NC}"
terraform plan -out=tfplan
show_success "Plano criado com sucesso!"

# Mostrar resumo do plano
echo ""
echo -e "${BLUE}📊 RESUMO DO PLANO:${NC}"
terraform show -json tfplan | jq -r '.resource_changes[] | select(.change.actions[] | contains("create")) | .type' | sort | uniq -c
echo ""

# Confirmação antes de aplicar
echo -e "${YELLOW}⚠️  ATENÇÃO: Você está prestes a criar recursos na AWS que geram custos!${NC}"
echo -e "${YELLOW}   Estimativa: ~\$2-3/dia durante testes${NC}"
echo -e "${YELLOW}   NAT Gateway: ~\$1/dia (componente mais caro)${NC}"
echo ""
echo -e "${YELLOW}Deseja continuar? (sim/não)${NC}"
read -r CONFIRM

if [ "$CONFIRM" != "sim" ]; then
    echo -e "${RED}❌ Deploy cancelado pelo usuário${NC}"
    exit 0
fi

# Etapa 5: Aplicar infraestrutura
show_progress "ETAPA 5/6: Criando infraestrutura na AWS"
echo -e "${BLUE}🚀 Iniciando deploy... Isso levará cerca de 10-15 minutos${NC}"
echo -e "${YELLOW}⏱️  Você pode acompanhar a criação dos recursos no AWS Console${NC}"
echo ""

# Aplicar com auto-approve
terraform apply tfplan

show_success "Infraestrutura criada com sucesso!"

# Etapa 6: Mostrar outputs
show_progress "ETAPA 6/6: Coletando informações da infraestrutura"

# Aguardar alguns segundos para garantir que tudo está pronto
echo -e "${YELLOW}Aguardando 10 segundos para os recursos estabilizarem...${NC}"
sleep 10

# Calcular tempo total
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║             ✓ DEPLOY CONCLUÍDO COM SUCESSO!                   ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}⏱️  Tempo total: ${MINUTES}m ${SECONDS}s${NC}"
echo ""
echo -e "${BLUE}📊 INFORMAÇÕES DA INFRAESTRUTURA:${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Obter outputs
WORDPRESS_URL=$(terraform output -raw wordpress_url 2>/dev/null || echo "Indisponível")
ALB_DNS=$(terraform output -raw alb_dns_name 2>/dev/null || echo "Indisponível")
VPC_ID=$(terraform output -raw vpc_id 2>/dev/null || echo "Indisponível")
EFS_ID=$(terraform output -raw efs_id 2>/dev/null || echo "Indisponível")
ASG_NAME=$(terraform output -raw asg_name 2>/dev/null || echo "Indisponível")

echo ""
echo -e "${GREEN}🌐 WordPress URL:${NC}"
echo -e "   $WORDPRESS_URL"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANTE: O WordPress pode levar alguns minutos para ficar disponível${NC}"
echo -e "${YELLOW}   aguarde enquanto as instâncias EC2 inicializam e passam nos health checks${NC}"
echo ""
echo -e "${BLUE}📋 Recursos Criados:${NC}"
echo -e "   • VPC ID: $VPC_ID"
echo -e "   • Load Balancer: $ALB_DNS"
echo -e "   • EFS ID: $EFS_ID"
echo -e "   • Auto Scaling Group: $ASG_NAME"
echo ""
echo -e "${BLUE}🔍 Comandos Úteis:${NC}"
echo -e "   • Ver todos outputs: ${YELLOW}terraform output${NC}"
echo -e "   • Ver recursos: ${YELLOW}terraform state list${NC}"
echo -e "   • Testar WordPress: ${YELLOW}curl -I $WORDPRESS_URL${NC}"
echo -e "   • Ver instâncias: ${YELLOW}aws ec2 describe-instances --filters \"Name=tag:Name,Values=*wordpress*\" --query 'Reservations[].Instances[].{ID:InstanceId,State:State.Name,IP:PrivateIpAddress}'${NC}"
echo ""
echo -e "${RED}⚠️  LEMBRE-SE DE DESTRUIR OS RECURSOS QUANDO TERMINAR:${NC}"
echo -e "${RED}   ./destroy.sh${NC}"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Salvar informações em arquivo
cat > deployment-info.txt <<EOF
=============================================================================
WORDPRESS INFRASTRUCTURE DEPLOYMENT
Deploy Time: $(date)
Duration: ${MINUTES}m ${SECONDS}s
=============================================================================

WordPress URL: $WORDPRESS_URL
Load Balancer DNS: $ALB_DNS
VPC ID: $VPC_ID
EFS ID: $EFS_ID
Auto Scaling Group: $ASG_NAME

=============================================================================
CUSTOS ESTIMADOS:
- NAT Gateway: ~$1.00/dia
- ALB: ~$0.50/dia  
- EC2 (t2.micro): Free tier ou ~$0.25/dia
- RDS (t3.micro): Free tier ou ~$0.50/dia
- EFS: ~$0.10-0.20/dia

Total estimado: $2-3/dia

IMPORTANTE: Destrua os recursos quando não estiver usando!
Comando: ./destroy.sh
=============================================================================
EOF

echo -e "${GREEN}✓ Informações salvas em deployment-info.txt${NC}"
echo ""
