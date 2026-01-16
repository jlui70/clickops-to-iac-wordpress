# Planejamento: Transição de ClickOps para IaC (Terraform)

## 📋 Visão Geral do Projeto

### Objetivo Principal
Demonstrar a transição de uma infraestrutura AWS criada manualmente (ClickOps) para Infrastructure as Code (IaC) usando Terraform, mantendo a mesma arquitetura WordPress escalável e altamente disponível.

### Sobre o Nome do Projeto Atual
O projeto atual se chama "projeto-docker-ansible-wordpress-aws" porque:
- **Docker**: WordPress roda em containers Docker nas instâncias EC2
- **Ansible**: Utilizado apenas para automação de fork/clone de repositórios (playbook.yml)
- **WordPress**: Aplicação principal
- **AWS**: Cloud provider

**Nota**: O Ansible aqui não provisiona infraestrutura AWS, apenas gerencia repositórios Git. A infraestrutura é toda manual (ClickOps).

---

## 🎯 Objetivos do Novo Projeto

### Objetivo Primário
Criar o **MESMO** projeto de infraestrutura WordPress na AWS, mas usando Terraform para demonstrar:

1. **Comparação de Tempo**
   - Tempo para provisionar via ClickOps vs Terraform
   - Tempo para recriar ambiente do zero
   - Tempo para modificar componentes existentes

2. **Benefícios do IaC**
   - Versionamento de infraestrutura
   - Reprodutibilidade
   - Documentação como código
   - Facilidade de manutenção
   - Menos erros humanos
   - Facilidade de destruir e recriar

3. **Comparação de Complexidade**
   - Quantidade de cliques vs linhas de código
   - Facilidade de entendimento
   - Curva de aprendizado

4. **Aspectos Operacionais**
   - Facilidade de rollback
   - Gerenciamento de mudanças
   - Trabalho em equipe
   - Auditoria e compliance

---

## 🏗️ Arquitetura a Ser Implementada

### Componentes (Idênticos ao Projeto Atual)

#### 1. **Networking**
- VPC customizada (10.0.0.0/16)
- 2 Subnets públicas (2 AZs)
- 2 Subnets privadas (2 AZs)
- Internet Gateway
- NAT Gateway (1 em subnet pública)
- Route Tables

#### 2. **Security Groups**
- `ApplicationLoadBalancer-SG` (porta 80/443 pública)
- `ApplicationServer-SG` (porta 80/443 do ALB, 3306 do RDS, 2049 do EFS)
- `Database-SG` (porta 3306 dos servidores)
- `EFS-SG` (porta 2049 dos servidores)

#### 3. **Database**
- RDS MySQL 8.4.3
- Instance class: db.t3.micro
- Storage: 20 GB SSD gp3
- Multi-AZ: Não (free tier)
- Backup: Desabilitado
- Subnet group privado

#### 4. **Storage**
- EFS (Elastic File System)
- Regional storage class
- Mount targets em subnets privadas
- Backup: Desabilitado

#### 5. **Compute**
- Launch Template com Amazon Linux 2
- Instance type: t2.micro
- User Data script com:
  - Docker
  - Docker Compose
  - NFS utils
  - SSM Agent
  - Montagem do EFS
  - Configuração do WordPress container

#### 6. **Load Balancing & Scaling**
- Application Load Balancer (público)
- Target Group (HTTP:80)
- Auto Scaling Group:
  - Desired: 2
  - Min: 1
  - Max: 2
  - Health checks: ELB

#### 7. **IAM**
- Role para EC2 com SSM access
- Policy: AmazonSSMManagedInstanceCore

---

## 📁 Estrutura do Novo Projeto

```
projeto-wordpress-clickops-vs-iac/
│
├── README.md                          # Documentação principal do projeto
├── COMPARACAO.md                      # Comparação detalhada ClickOps vs IaC
├── METRICAS.md                        # Métricas coletadas durante implementação
│
├── clickops/                          # Documentação ClickOps (referência atual)
│   ├── README.md                      # Cópia do projeto atual
│   ├── instrucoes-detalhadas.md       # Passo a passo com screenshots
│   └── Img/                           # Imagens e diagramas
│
├── terraform/                         # Implementação IaC
│   ├── README.md                      # Instruções Terraform
│   ├── versions.tf                    # Versões de providers
│   ├── variables.tf                   # Variáveis de entrada
│   ├── terraform.tfvars.example       # Exemplo de valores
│   ├── outputs.tf                     # Outputs importantes
│   ├── main.tf                        # Recursos principais
│   │
│   ├── modules/                       # Módulos Terraform organizados
│   │   ├── networking/
│   │   │   ├── main.tf               # VPC, Subnets, IGW, NAT
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   ├── security-groups/
│   │   │   ├── main.tf               # Todos os SGs
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   ├── database/
│   │   │   ├── main.tf               # RDS MySQL
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   ├── efs/
│   │   │   ├── main.tf               # EFS file system
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   ├── iam/
│   │   │   ├── main.tf               # Roles e policies
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   ├── compute/
│   │   │   ├── main.tf               # Launch Template
│   │   │   ├── user-data.sh          # Script separado
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   └── load-balancing/
│   │       ├── main.tf               # ALB, TG, ASG
│   │       ├── variables.tf
│   │       └── outputs.tf
│   │
│   ├── environments/                  # Ambientes separados
│   │   ├── dev/
│   │   │   ├── main.tf
│   │   │   ├── terraform.tfvars
│   │   │   └── backend.tf
│   │   └── prod/
│   │       ├── main.tf
│   │       ├── terraform.tfvars
│   │       └── backend.tf
│   │
│   └── scripts/                       # Scripts auxiliares
│       ├── deploy.sh                  # Script de deploy completo
│       ├── destroy.sh                 # Script de destruição segura
│       └── validate.sh                # Validação pós-deploy
│
├── docs/                              # Documentação adicional
│   ├── architecture-diagram.png       # Diagrama de arquitetura
│   ├── terraform-graph.png            # Grafo de dependências
│   ├── cost-analysis.md               # Análise de custos
│   └── best-practices.md              # Melhores práticas aplicadas
│
├── tests/                             # Testes de infraestrutura
│   ├── terraform-validation.sh        # Testes básicos
│   └── integration-tests.sh           # Testes de integração
│
└── ansible/                           # Mantém o playbook original
    ├── playbook.yml
    └── vars/
        └── repos.yml
```

---

## 📊 Métricas a Serem Coletadas

### Durante Implementação ClickOps
- [ ] Tempo total para criar toda infraestrutura (cronometrado)
- [ ] Número de cliques necessários (estimado)
- [ ] Número de erros cometidos
- [ ] Número de passos manuais
- [ ] Tempo para identificar e corrigir erros

### Durante Implementação Terraform
- [ ] Tempo para escrever o código Terraform
- [ ] Tempo de execução do `terraform apply`
- [ ] Número de linhas de código
- [ ] Número de recursos gerenciados
- [ ] Tempo para modificar um componente
- [ ] Tempo para destruir tudo (`terraform destroy`)

### Comparação
- [ ] Facilidade de replicação
- [ ] Facilidade de versionamento
- [ ] Facilidade de manutenção
- [ ] Facilidade de documentação
- [ ] Facilidade de rollback
- [ ] Facilidade de trabalho em equipe

---

## 🎬 Roadmap de Implementação

### Fase 1: Preparação (1-2 dias)
- [x] Análise completa do projeto ClickOps existente
- [ ] Criar estrutura de pastas do novo projeto
- [ ] Criar repositório Git
- [ ] Documentar arquitetura atual
- [ ] Definir métricas a coletar

### Fase 2: Implementação ClickOps Documentada (2-3 dias)
- [ ] Seguir o guia existente passo a passo
- [ ] Cronometrar cada etapa
- [ ] Tirar screenshots de cada passo
- [ ] Documentar erros encontrados
- [ ] Anotar dificuldades
- [ ] Testar a aplicação
- [ ] Documentar processo de destruição

### Fase 3: Implementação Terraform - Base (3-4 dias)
- [ ] Configurar providers e backend
- [ ] Módulo de Networking
  - [ ] VPC
  - [ ] Subnets
  - [ ] Internet Gateway
  - [ ] NAT Gateway
  - [ ] Route Tables
- [ ] Módulo de Security Groups
  - [ ] ALB-SG
  - [ ] App-SG
  - [ ] DB-SG
  - [ ] EFS-SG
- [ ] Módulo IAM
  - [ ] EC2 Role
  - [ ] SSM Policy

### Fase 4: Implementação Terraform - Serviços (3-4 dias)
- [ ] Módulo RDS
  - [ ] Subnet Group
  - [ ] MySQL instance
  - [ ] Parameter Group
- [ ] Módulo EFS
  - [ ] File System
  - [ ] Mount Targets
  - [ ] Access Points
- [ ] Módulo Compute
  - [ ] Launch Template
  - [ ] User Data script
- [ ] Módulo Load Balancing
  - [ ] Target Group
  - [ ] Application Load Balancer
  - [ ] Listeners
  - [ ] Auto Scaling Group

### Fase 5: Testes e Validação (2-3 dias)
- [ ] Validar conectividade
- [ ] Testar Auto Scaling
- [ ] Testar persistência (EFS)
- [ ] Testar banco de dados
- [ ] Testar Load Balancer
- [ ] Instalar e configurar WordPress
- [ ] Testes de carga básicos

### Fase 6: Documentação e Comparação (2-3 dias)
- [ ] Escrever README principal
- [ ] Criar COMPARACAO.md detalhado
- [ ] Criar METRICAS.md com dados coletados
- [ ] Criar diagramas comparativos
- [ ] Documentar lições aprendidas
- [ ] Criar vídeo/apresentação (opcional)

### Fase 7: Refinamento (1-2 dias)
- [ ] Adicionar outputs úteis
- [ ] Melhorar comentários no código
- [ ] Adicionar validações
- [ ] Criar scripts auxiliares
- [ ] Revisar documentação
- [ ] Publicar projeto

**Tempo Total Estimado: 14-21 dias**

---

## 💡 Diferenciais do Projeto

### 1. **Comparação Prática e Concreta**
- Não apenas teoria, mas implementação real dos dois métodos
- Dados reais de tempo, complexidade e esforço

### 2. **Documentação Detalhada**
- Cada passo documentado
- Screenshots e diagramas
- Código comentado

### 3. **Modularização do Terraform**
- Código organizado e reutilizável
- Seguindo best practices
- Fácil de entender e manter

### 4. **Métricas Concretas**
- Comparação quantitativa
- Dados mensuráveis
- Análise objetiva

### 5. **Reprodutibilidade**
- Qualquer pessoa pode replicar
- Ambiente dev e prod
- Documentação completa

---

## 🎓 Lições a Demonstrar

### Vantagens do IaC
1. **Versionamento**: Git tracking de todas as mudanças
2. **Reprodutibilidade**: Mesmo ambiente sempre
3. **Velocidade**: Provisionamento em minutos vs horas
4. **Menos erros**: Validação automática
5. **Colaboração**: Code review, PRs, etc.
6. **Documentação**: Código é a documentação
7. **Rollback**: Fácil voltar para versão anterior
8. **Testes**: Possível testar mudanças antes de aplicar
9. **Modularidade**: Reutilização de componentes
10. **Consistência**: Mesma infraestrutura sempre

### Desafios do IaC
1. **Curva de aprendizado**: Precisa aprender Terraform/HCL
2. **Tempo inicial**: Mais tempo para primeira implementação
3. **Complexidade inicial**: Parece mais complexo no início
4. **Manutenção do código**: Precisa manter código atualizado
5. **State management**: Gerenciar estado do Terraform

### Quando Usar Cada Abordagem

#### ClickOps (Interface Web)
- ✅ Prototipação rápida
- ✅ Exploração de novos serviços
- ✅ Projetos descartáveis
- ✅ Aprendizado inicial
- ✅ Troubleshooting pontual

#### IaC (Terraform)
- ✅ Ambientes de produção
- ✅ Múltiplos ambientes (dev/staging/prod)
- ✅ Infraestrutura que precisa ser replicada
- ✅ Trabalho em equipe
- ✅ Compliance e auditoria
- ✅ Infraestrutura complexa
- ✅ Disaster recovery

---

## 📈 KPIs de Sucesso do Projeto

1. **Funcionalidade**: Ambas implementações funcionam identicamente
2. **Documentação**: Guia claro e completo
3. **Métricas**: Dados concretos coletados
4. **Código**: Terraform bem estruturado e comentado
5. **Reprodutibilidade**: Outros podem replicar
6. **Comparação**: Análise objetiva e justa

---

## 🚀 Próximos Passos Imediatos

1. **Criar nova estrutura de projeto**
   ```bash
   mkdir projeto-wordpress-clickops-vs-iac
   cd projeto-wordpress-clickops-vs-iac
   git init
   # Criar estrutura de pastas
   ```

2. **Copiar documentação ClickOps existente**
   ```bash
   mkdir -p clickops
   cp -r ../projeto-docker-ansible-wordpress-aws/* clickops/
   ```

3. **Iniciar implementação Terraform**
   ```bash
   mkdir -p terraform/modules
   # Criar arquivos base do Terraform
   ```

4. **Começar cronometragem**
   - Iniciar timer para implementação ClickOps
   - Documentar cada passo

---

## 📚 Recursos Necessários

### Conhecimentos
- [x] AWS Services (VPC, EC2, RDS, EFS, ALB, ASG)
- [ ] Terraform (HCL syntax, providers, modules, state)
- [ ] Docker e Docker Compose
- [ ] Linux/Shell scripting
- [ ] WordPress básico

### Ferramentas
- [ ] Conta AWS (Free Tier é suficiente, mas atenção aos custos)
- [ ] Terraform CLI instalado
- [ ] AWS CLI configurado
- [ ] Git
- [ ] Editor de código (VS Code)
- [ ] Ferramentas de diagramação (draw.io, etc.)

### Custos Estimados AWS (por hora)
- NAT Gateway: ~$0.045/hora (~$32/mês)
- RDS db.t3.micro: Free tier (750h/mês)
- EC2 t2.micro: Free tier (750h/mês)
- ALB: ~$0.0225/hora (~$16/mês)
- EFS: $0.30/GB-mês (mínimo)
- **Total estimado: $50-60/mês se ultrapassar free tier**

**Recomendação**: Destruir recursos quando não estiver testando!

---

## 🎯 Resultado Final Esperado

Um projeto completo que:
1. ✅ Demonstra claramente a diferença entre ClickOps e IaC
2. ✅ Fornece dados concretos e métricas
3. ✅ Serve como material educacional
4. ✅ Pode ser usado em portfólio
5. ✅ Ajuda outros a entender os benefícios do IaC
6. ✅ Mostra boas práticas de Terraform
7. ✅ É totalmente reproduzível

---

## 📝 Notas Importantes

### Segurança
- ⚠️ Não commitar credenciais no Git
- ⚠️ Usar AWS Secrets Manager ou SSM Parameter Store
- ⚠️ Usar `.gitignore` para arquivos sensíveis
- ⚠️ Ativar MFA na conta AWS

### Custos
- ⚠️ NAT Gateway é o componente mais caro
- ⚠️ Destruir recursos quando não usar
- ⚠️ Configurar billing alerts
- ⚠️ Considerar usar NAT Instance (mais barato) para testes

### State Management
- ⚠️ Usar S3 backend para Terraform state
- ⚠️ Ativar versionamento no bucket S3
- ⚠️ Usar DynamoDB para state locking
- ⚠️ Backup regular do state file

---

## 🤝 Como Contribuir (se publicar)

Se decidir tornar público:
1. Issues para reportar problemas
2. PRs para melhorias
3. Discussões para sugestões
4. Stars para dar visibilidade

---

## 📧 Contato

_[Adicionar informações de contato se desejar]_

---

**Última atualização**: Janeiro 2026
**Status**: 📝 Planejamento Completo - Pronto para Implementação
