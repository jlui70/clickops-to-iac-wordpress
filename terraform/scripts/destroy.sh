#!/bin/bash

# =============================================================================
# Script de Destroy Automatizado - Limpeza Completa da Infraestrutura
# =============================================================================

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${RED}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║        WordPress Infrastructure Destruction - Terraform       ║${NC}"
echo -e "${RED}║              ATENÇÃO: Esta ação é IRREVERSÍVEL!                ║${NC}"
echo -e "${RED}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Verificar se estamos no diretório correto
if [ ! -f "versions.tf" ]; then
    echo -e "${RED}❌ Erro: Execute este script do diretório terraform/${NC}"
    exit 1
fi

# Verificar se há infraestrutura para destruir
if [ ! -f "terraform.tfstate" ]; then
    echo -e "${YELLOW}⚠️  Nenhuma infraestrutura encontrada (terraform.tfstate não existe)${NC}"
    exit 0
fi

# Função para mostrar progresso
show_progress() {
    echo ""
    echo -e "${BLUE}▶ $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Função para mostrar sucesso
show_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Mostrar recursos que serão destruídos
show_progress "Verificando recursos existentes"
terraform state list

echo ""
echo -e "${RED}⚠️  CONFIRMAÇÃO NECESSÁRIA${NC}"
echo -e "${YELLOW}Os seguintes recursos serão PERMANENTEMENTE DESTRUÍDOS:${NC}"
echo ""
terraform show -json | jq -r '.values.root_module.resources[].address' 2>/dev/null || terraform state list
echo ""

# Tripla confirmação
echo -e "${RED}Esta ação NÃO PODE ser desfeita!${NC}"
echo -e "${YELLOW}Digite 'DESTRUIR' (em maiúsculas) para confirmar:${NC}"
read -r CONFIRM1

if [ "$CONFIRM1" != "DESTRUIR" ]; then
    echo -e "${GREEN}✓ Operação cancelada. Nenhum recurso foi destruído.${NC}"
    exit 0
fi

echo ""
echo -e "${RED}Tem certeza ABSOLUTA? Digite 'sim' para confirmar:${NC}"
read -r CONFIRM2

if [ "$CONFIRM2" != "sim" ]; then
    echo -e "${GREEN}✓ Operação cancelada. Nenhum recurso foi destruído.${NC}"
    exit 0
fi

# Início do cronômetro
START_TIME=$(date +%s)

# Etapa 1: Planejar destruição
show_progress "ETAPA 1/3: Planejando destruição"
terraform plan -destroy -out=destroy.tfplan
show_success "Plano de destruição criado!"

# Etapa 2: Executar destruição
show_progress "ETAPA 2/3: Destruindo infraestrutura"
echo -e "${RED}🗑️  Iniciando destruição... Isso levará cerca de 8-12 minutos${NC}"
echo -e "${YELLOW}⏱️  Você pode acompanhar a remoção dos recursos no AWS Console${NC}"
echo ""

# Ordem correta de destruição (Terraform gerencia isso, mas para referência):
# 1. Auto Scaling Group (desliga instâncias)
# 2. Load Balancer e Target Group
# 3. Launch Template
# 4. EFS Mount Targets
# 5. EFS File System
# 6. RDS Instance
# 7. NAT Gateway
# 8. Internet Gateway
# 9. Route Tables
# 10. Subnets
# 11. Security Groups
# 12. VPC
# 13. IAM Resources

terraform apply destroy.tfplan

show_success "Recursos destruídos com sucesso!"

# Etapa 3: Limpeza de arquivos
show_progress "ETAPA 3/3: Limpando arquivos temporários"

# Remover arquivos de plano
rm -f tfplan destroy.tfplan

# Manter terraform.tfstate para histórico, mas avisar
echo -e "${YELLOW}⚠️  Arquivos terraform.tfstate foram mantidos para histórico${NC}"
echo -e "${YELLOW}   Se desejar removê-los: rm -f terraform.tfstate*${NC}"

show_success "Limpeza concluída!"

# Calcular tempo total
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         ✓ DESTRUIÇÃO CONCLUÍDA COM SUCESSO!                   ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}⏱️  Tempo total: ${MINUTES}m ${SECONDS}s${NC}"
echo ""
echo -e "${GREEN}✓ Todos os recursos AWS foram removidos${NC}"
echo -e "${GREEN}✓ Billing interrompido - não haverá mais custos${NC}"
echo ""
echo -e "${BLUE}📊 Verificações Recomendadas:${NC}"
echo -e "   1. Verifique o AWS Console para confirmar remoção"
echo -e "   2. Verifique AWS Cost Explorer nas próximas horas"
echo -e "   3. Confirme que não há recursos órfãos"
echo ""
echo -e "${YELLOW}🔍 Comandos para verificar limpeza:${NC}"
echo -e "   ${YELLOW}# VPCs${NC}"
echo -e "   aws ec2 describe-vpcs --filters \"Name=tag:Project,Values=WordPress-ClickOps-vs-IaC\""
echo ""
echo -e "   ${YELLOW}# Instâncias EC2${NC}"
echo -e "   aws ec2 describe-instances --filters \"Name=tag:Environment,Values=dev\" --query 'Reservations[].Instances[].State.Name'"
echo ""
echo -e "   ${YELLOW}# NAT Gateways${NC}"
echo -e "   aws ec2 describe-nat-gateways --filter \"Name=state,Values=available\""
echo ""
echo -e "   ${YELLOW}# Load Balancers${NC}"
echo -e "   aws elbv2 describe-load-balancers --query 'LoadBalancers[?contains(LoadBalancerName, \`wp-docker\`)].LoadBalancerName'"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Salvar log de destruição
cat > destruction-log.txt <<EOF
=============================================================================
WORDPRESS INFRASTRUCTURE DESTRUCTION LOG
Destruction Time: $(date)
Duration: ${MINUTES}m ${SECONDS}s
=============================================================================

STATUS: All resources successfully destroyed

NEXT STEPS:
1. Verify AWS Console for complete removal
2. Check Cost Explorer in a few hours
3. Confirm no orphaned resources remain

=============================================================================
VERIFICATION COMMANDS:
- VPCs: aws ec2 describe-vpcs --filters "Name=tag:Project,Values=WordPress-ClickOps-vs-IaC"
- EC2: aws ec2 describe-instances --filters "Name=tag:Environment,Values=dev"
- NAT Gateways: aws ec2 describe-nat-gateways --filter "Name=state,Values=available"
- Load Balancers: aws elbv2 describe-load-balancers
=============================================================================
EOF

echo -e "${GREEN}✓ Log salvo em destruction-log.txt${NC}"
echo ""
echo -e "${GREEN}🎉 Infraestrutura completamente removida! Custos interrompidos.${NC}"
echo ""
