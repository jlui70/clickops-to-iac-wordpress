# ✅ CHECKLIST DE IMPLEMENTAÇÃO

## 📚 FASE 0: PREPARAÇÃO (ANTES DE COMEÇAR)

### Entendimento
- [ ] Li o [RESUMO-EXECUTIVO.md](RESUMO-EXECUTIVO.md) completo
- [ ] Li o [PLANEJAMENTO.md](PLANEJAMENTO.md) completo
- [ ] Entendi a arquitetura WordPress a ser criada
- [ ] Entendi diferença entre ClickOps e IaC
- [ ] Decidi: Vale a pena fazer? **SIM / NÃO**

### Recursos
- [ ] Conta AWS criada e verificada
- [ ] Cartão de crédito válido cadastrado
- [ ] Free Tier disponível (ou orçamento de ~$20-30)
- [ ] Região AWS selecionada: _______________
- [ ] Tempo disponível: 2-3 semanas (dedicação parcial)

### Ferramentas
```bash
# Verificar instalações:
- [ ] aws --version              # AWS CLI v2
- [ ] terraform --version        # >= 1.0
- [ ] docker --version
- [ ] git --version
- [ ] Editor de código instalado (VS Code recomendado)
```

### Configuração AWS
```bash
- [ ] aws configure (executado e testado)
- [ ] Billing Alerts configurados ($10, $20, $50)
- [ ] MFA ativado (recomendado)
- [ ] IAM user com permissões adequadas
```

### Setup Projeto
```bash
# Execute os comandos:
- [ ] mkdir projeto-wordpress-clickops-vs-iac
- [ ] cd projeto-wordpress-clickops-vs-iac
- [ ] git init
- [ ] Estrutura de pastas criada (ver GUIA-RAPIDO.md)
- [ ] .gitignore configurado
- [ ] README.md inicial criado
```

---

## 📋 FASE 1: IMPLEMENTAÇÃO CLICKOPS (Semana 1)

### Preparação
- [ ] Cronômetro preparado ⏱️
- [ ] Planilha para anotar métricas pronta
- [ ] Ferramenta de screenshot pronta
- [ ] Leu o README.md original (guia ClickOps)

### Implementação (Seguir README.md)
**⏱️ START TIMER: ___:___**

#### Parte 1: VPC e Networking (15-20 min)
- [ ] 1.1 VPC criada (10.0.0.0/16)
- [ ] 1.2 NAT Gateway criado
- [ ] 1.3 Route Tables associadas
- [ ] Screenshot tirado
- [ ] Tempo parcial: ___ min

#### Parte 2: Security Groups (20-25 min)
- [ ] 2.1 ApplicationLoadBalancer-SG
- [ ] 2.2 ApplicationServer-SG
- [ ] 2.3 Database-SG
- [ ] 2.4 EFS-SG
- [ ] Screenshot tirado
- [ ] Tempo parcial: ___ min

#### Parte 3: IAM Role (5 min)
- [ ] EC2-SSM-Role criada
- [ ] Policy AmazonSSMManagedInstanceCore attached
- [ ] Screenshot tirado
- [ ] Tempo parcial: ___ min

#### Parte 4: RDS Database (10 min + 15 min criação)
- [ ] 4.1 Subnet Group criado
- [ ] 4.2 RDS MySQL criado (db.t3.micro)
- [ ] Aguardou criação (Available)
- [ ] Endpoint anotado: _______________
- [ ] Screenshot tirado
- [ ] Tempo parcial: ___ min

#### Parte 5: EFS (10 min)
- [ ] 5.1 File System criado
- [ ] 5.2 DNS name anotado: _______________
- [ ] Mount targets configurados
- [ ] Screenshot tirado
- [ ] Tempo parcial: ___ min

#### Parte 6: Launch Template (15-20 min)
- [ ] Template criado
- [ ] User Data script configurado (EFS e RDS DNS)
- [ ] IAM Instance Profile associado
- [ ] Screenshot tirado
- [ ] Tempo parcial: ___ min

#### Parte 7: Load Balancer (10 min)
- [ ] 7.1 Target Group criado
- [ ] 7.2 Application Load Balancer criado
- [ ] Listener configurado
- [ ] DNS do ALB anotado: _______________
- [ ] Screenshot tirado
- [ ] Tempo parcial: ___ min

#### Parte 8: Auto Scaling Group (10 min)
- [ ] ASG criado (Min: 1, Desired: 2, Max: 2)
- [ ] Attached ao ALB
- [ ] Health checks configurados
- [ ] Screenshot tirado
- [ ] Tempo parcial: ___ min

#### Parte 9: Testes (10-15 min)
- [ ] Aguardou instâncias ficarem Healthy
- [ ] Acessou ALB DNS no navegador
- [ ] WordPress carregou corretamente
- [ ] Configurou WordPress
- [ ] Testou persistência (upload de mídia)
- [ ] Testou múltiplas instâncias
- [ ] Screenshots tirados
- [ ] Tempo parcial: ___ min

**⏱️ STOP TIMER: ___:___**

### Métricas ClickOps
```
Tempo total: _______ minutos
Número de passos: _______ (contar do README)
Número estimado de cliques: ~300-400
Erros cometidos: _______
Tempo para corrigir erros: _______ minutos
Dificuldade (1-10): _______
```

### Documentação
- [ ] Preencher `clickops/METRICAS-CLICKOPS.md`
- [ ] Salvar screenshots em `clickops/Img/`
- [ ] Anotar dificuldades encontradas
- [ ] Anotar pontos confusos
- [ ] Anotar erros comuns

### Destruição ClickOps
**⏱️ START DESTROY TIMER: ___:___**

- [ ] Auto Scaling Group deletado
- [ ] Load Balancer deletado
- [ ] Target Group deletado
- [ ] Launch Template deletado
- [ ] Instâncias EC2 terminadas
- [ ] EFS deletado
- [ ] RDS deletado (aguardar)
- [ ] Security Groups deletados
- [ ] NAT Gateway deletado
- [ ] Elastic IP released
- [ ] Route Tables default restauradas
- [ ] Subnets deletadas
- [ ] Internet Gateway detached e deletado
- [ ] VPC deletada
- [ ] IAM Role deletada

**⏱️ STOP DESTROY TIMER: ___:___**

```
Tempo de destruição: _______ minutos
Dificuldade de destruição (1-10): _______
```

---

## 💻 FASE 2: IMPLEMENTAÇÃO TERRAFORM (Semana 2-3)

### Preparação Terraform
- [ ] Leu [EXEMPLO-MODULO-TERRAFORM.md](EXEMPLO-MODULO-TERRAFORM.md)
- [ ] Estrutura de pastas Terraform criada
- [ ] versions.tf criado
- [ ] variables.tf criado
- [ ] terraform.tfvars.example criado
- [ ] terraform.tfvars criado (com credenciais)
- [ ] outputs.tf criado

### Módulo 1: Networking (Dia 1)
**⏱️ START CODING TIMER: ___:___**

- [ ] `modules/networking/main.tf` criado
  - [ ] VPC
  - [ ] Internet Gateway
  - [ ] Subnets públicas (2)
  - [ ] Subnets privadas (2)
  - [ ] Elastic IP
  - [ ] NAT Gateway
  - [ ] Route Table pública
  - [ ] Route Tables privadas (2)
  - [ ] Routes configuradas
  - [ ] Associations configuradas
- [ ] `modules/networking/variables.tf` criado
- [ ] `modules/networking/outputs.tf` criado
- [ ] Testado: `terraform init`
- [ ] Testado: `terraform validate`
- [ ] Testado: `terraform plan -target=module.networking`

**⏱️ STOP CODING TIMER: ___:___**

```
Tempo para escrever: _______ minutos
Linhas de código: _______
```

### Módulo 2: Security Groups (Dia 2)
**⏱️ START CODING TIMER: ___:___**

- [ ] `modules/security-groups/main.tf` criado
  - [ ] ALB-SG (ports 80, 443 in; 80, 443 out)
  - [ ] App-SG (ports 80, 443, 3306, 2049)
  - [ ] DB-SG (port 3306)
  - [ ] EFS-SG (port 2049)
- [ ] `modules/security-groups/variables.tf` criado
- [ ] `modules/security-groups/outputs.tf` criado
- [ ] Testado isoladamente

**⏱️ STOP CODING TIMER: ___:___**

```
Tempo para escrever: _______ minutos
Linhas de código: _______
```

### Módulo 3: IAM (Dia 3)
**⏱️ START CODING TIMER: ___:___**

- [ ] `modules/iam/main.tf` criado
  - [ ] IAM Role para EC2
  - [ ] Assume Role Policy
  - [ ] Policy Attachment (SSM)
  - [ ] Instance Profile
- [ ] `modules/iam/variables.tf` criado
- [ ] `modules/iam/outputs.tf` criado
- [ ] Testado isoladamente

**⏱️ STOP CODING TIMER: ___:___**

```
Tempo para escrever: _______ minutos
Linhas de código: _______
```

### Módulo 4: Database (Dia 4)
**⏱️ START CODING TIMER: ___:___**

- [ ] `modules/database/main.tf` criado
  - [ ] DB Subnet Group
  - [ ] RDS MySQL Instance
  - [ ] Parameter Group (opcional)
- [ ] `modules/database/variables.tf` criado
- [ ] `modules/database/outputs.tf` criado
- [ ] Testado isoladamente

**⏱️ STOP CODING TIMER: ___:___**

```
Tempo para escrever: _______ minutos
Linhas de código: _______
```

### Módulo 5: EFS (Dia 5)
**⏱️ START CODING TIMER: ___:___**

- [ ] `modules/efs/main.tf` criado
  - [ ] EFS File System
  - [ ] Mount Targets (2 AZs)
- [ ] `modules/efs/variables.tf` criado
- [ ] `modules/efs/outputs.tf` criado
- [ ] Testado isoladamente

**⏱️ STOP CODING TIMER: ___:___**

```
Tempo para escrever: _______ minutos
Linhas de código: _______
```

### Módulo 6: Compute (Dia 6)
**⏱️ START CODING TIMER: ___:___**

- [ ] `modules/compute/user-data.sh` criado
- [ ] `modules/compute/main.tf` criado
  - [ ] Data source para user-data
  - [ ] Launch Template
- [ ] `modules/compute/variables.tf` criado
- [ ] `modules/compute/outputs.tf` criado
- [ ] Testado isoladamente

**⏱️ STOP CODING TIMER: ___:___**

```
Tempo para escrever: _______ minutos
Linhas de código: _______
```

### Módulo 7: Load Balancing (Dia 7)
**⏱️ START CODING TIMER: ___:___**

- [ ] `modules/load-balancing/main.tf` criado
  - [ ] Target Group
  - [ ] Application Load Balancer
  - [ ] Listener
  - [ ] Auto Scaling Group
  - [ ] ASG Attachment
- [ ] `modules/load-balancing/variables.tf` criado
- [ ] `modules/load-balancing/outputs.tf` criado
- [ ] Testado isoladamente

**⏱️ STOP CODING TIMER: ___:___**

```
Tempo para escrever: _______ minutos
Linhas de código: _______
```

### Integração Final (Dia 8)
**⏱️ START INTEGRATION TIMER: ___:___**

- [ ] `main.tf` principal criado
- [ ] Todos módulos chamados
- [ ] Dependências configuradas
- [ ] Outputs principais configurados
- [ ] `terraform init` executado
- [ ] `terraform validate` OK
- [ ] `terraform fmt -recursive` executado
- [ ] `terraform plan` analisado

**⏱️ STOP INTEGRATION TIMER: ___:___**

```
Tempo para integrar: _______ minutos
Warnings/Errors encontrados: _______
```

### Deploy Terraform (Dia 9)
**⏱️ START APPLY TIMER: ___:___**

```bash
terraform apply
```

- [ ] Apply executado
- [ ] Recursos criados com sucesso
- [ ] Outputs verificados
- [ ] ALB DNS anotado: _______________
- [ ] Instâncias EC2 verificadas

**⏱️ STOP APPLY TIMER: ___:___**

```
Tempo de apply: _______ minutos
Recursos criados: _______ (terraform state list | wc -l)
```

### Testes Terraform (Dia 9)
- [ ] Aguardou Target Group Healthy
- [ ] Acessou ALB DNS
- [ ] WordPress carregou
- [ ] Configurou WordPress
- [ ] Testou persistência (EFS)
- [ ] Testou auto scaling
- [ ] Acessou EC2 via SSM
- [ ] Verificou logs CloudWatch
- [ ] Screenshots tirados

### Métricas Terraform
```
Tempo para escrever código: _______ horas
Tempo de execução (apply): _______ minutos
Linhas de código total: _______
Módulos criados: 7
Recursos gerenciados: _______
Erros durante desenvolvimento: _______
Tempo para corrigir: _______ minutos
Dificuldade (1-10): _______
```

### Teste de Replicação
**⏱️ START REPLICATION TIMER: ___:___**

```bash
terraform destroy -auto-approve
# Aguardar destruição completa
terraform apply -auto-approve
```

- [ ] Destroy executado
- [ ] Recursos destruídos
- [ ] Apply executado novamente
- [ ] Infraestrutura recriada identicamente
- [ ] WordPress funcionando

**⏱️ STOP REPLICATION TIMER: ___:___**

```
Tempo de destruição: _______ minutos
Tempo de recriação: _______ minutos
Total: _______ minutos
```

### Destruição Final Terraform
**⏱️ START FINAL DESTROY TIMER: ___:___**

```bash
terraform destroy -auto-approve
```

- [ ] Todos recursos destruídos
- [ ] Verificado no AWS Console
- [ ] Custos finais verificados

**⏱️ STOP FINAL DESTROY TIMER: ___:___**

---

## 📊 FASE 3: COMPARAÇÃO E ANÁLISE (Semana 4)

### Coleta de Dados (Dia 10)
- [ ] Planilha comparativa criada
- [ ] Dados ClickOps consolidados
- [ ] Dados Terraform consolidados
- [ ] Cálculos de ROI feitos
- [ ] Gráficos criados (opcional)

### Template de Dados
```
┌─────────────────────────┬──────────────┬───────────────┐
│ Métrica                 │   ClickOps   │   Terraform   │
├─────────────────────────┼──────────────┼───────────────┤
│ Tempo implementação     │ ___ min      │ ___ horas     │
│ Tempo replicação        │ ___ min      │ ___ min       │
│ Tempo destruição        │ ___ min      │ ___ min       │
│ Passos manuais          │ ~100         │ ~5            │
│ Linhas código/doc       │ ~400 (doc)   │ ___ (código)  │
│ Possibilidade erro      │ Alta         │ Baixa         │
│ Reprodutibilidade       │ Não          │ 100%          │
│ Versionamento           │ Não          │ Git           │
│ Dificuldade (1-10)      │ ___          │ ___           │
└─────────────────────────┴──────────────┴───────────────┘
```

### Documentação (Dia 11-12)
- [ ] `COMPARACAO.md` escrito (baseado no template)
- [ ] Dados reais inseridos
- [ ] Análise qualitativa adicionada
- [ ] Conclusões escritas
- [ ] Recomendações documentadas
- [ ] Lições aprendidas listadas

### Material Visual (Dia 13)
- [ ] Diagramas de arquitetura criados
- [ ] Fluxogramas de processo criados
- [ ] Screenshots organizados
- [ ] Gráficos comparativos criados (tempo, custos)
- [ ] Terraform graph gerado
  ```bash
  terraform graph | dot -Tpng > docs/terraform-graph.png
  ```

### README Principal (Dia 14)
- [ ] README.md principal atualizado
- [ ] Badges adicionados (opcional)
- [ ] Seções organizadas:
  - [ ] Visão geral
  - [ ] Arquitetura
  - [ ] Como usar (ClickOps)
  - [ ] Como usar (Terraform)
  - [ ] Comparação (resumo)
  - [ ] Resultados
  - [ ] Conclusões
  - [ ] Recursos adicionais
  - [ ] Licença
  - [ ] Contato

---

## 📢 FASE 4: PUBLICAÇÃO (Opcional)

### GitHub
- [ ] Repositório criado no GitHub
- [ ] README.md bem formatado
- [ ] .gitignore configurado
- [ ] Commits organizados e descritivos
- [ ] Tags de versão criadas
- [ ] Licença adicionada (MIT recomendada)
- [ ] Repository description preenchido
- [ ] Topics/tags adicionados:
  - `terraform`
  - `aws`
  - `infrastructure-as-code`
  - `wordpress`
  - `devops`
  - `comparison`
  - `clickops`

### Artigo (Opcional)
- [ ] Plataforma escolhida (Medium, Dev.to, etc)
- [ ] Artigo escrito
- [ ] Screenshots inseridos
- [ ] Código formatado
- [ ] Links para GitHub adicionados
- [ ] Publicado
- [ ] Compartilhado nas redes

### LinkedIn (Opcional)
- [ ] Post sobre o projeto
- [ ] Screenshots/resultados compartilhados
- [ ] Link para GitHub
- [ ] Tags relevantes (#DevOps #Terraform #AWS #IaC)

### Apresentação (Opcional)
- [ ] Slides criados
- [ ] Demo preparado
- [ ] Apresentado em meetup/comunidade

---

## 💰 CUSTOS FINAIS

### Acompanhamento
```
Data início: ___/___/___
Data fim: ___/___/___
Duração total: ___ dias

Custos AWS incorridos:
- ClickOps (criação + testes): $______
- Terraform (criação + testes): $______
- Total: $______

Tempo investido:
- Planejamento: ___ horas
- ClickOps: ___ horas
- Terraform: ___ horas
- Documentação: ___ horas
- Total: ___ horas

Custo hora (se aplicável): $______
Valor total investido: $______
```

---

## ✅ CHECKLIST FINAL DE QUALIDADE

### Código
- [ ] Terraform validate OK
- [ ] Terraform fmt OK
- [ ] Sem hardcoded secrets
- [ ] Variáveis documentadas
- [ ] Outputs úteis
- [ ] Comentários adequados
- [ ] Modularização lógica
- [ ] Naming conventions consistentes

### Documentação
- [ ] README claro e completo
- [ ] Passo a passo funciona
- [ ] Screenshots legíveis
- [ ] Links funcionando
- [ ] Português correto
- [ ] Informações atualizadas

### Funcionalidade
- [ ] ClickOps funciona 100%
- [ ] Terraform funciona 100%
- [ ] WordPress acessível (ambos)
- [ ] Persistência funciona
- [ ] Auto Scaling funciona
- [ ] SSM access funciona

### Comparação
- [ ] Métricas coletadas
- [ ] Análise objetiva
- [ ] Dados reais (não estimados)
- [ ] Conclusões baseadas em evidências
- [ ] Recomendações práticas

---

## 🎯 STATUS DO PROJETO

```
Fase 0 - Preparação:           [ ] Não iniciado  [ ] Em progresso  [ ] Completo
Fase 1 - ClickOps:             [ ] Não iniciado  [ ] Em progresso  [ ] Completo
Fase 2 - Terraform:            [ ] Não iniciado  [ ] Em progresso  [ ] Completo
Fase 3 - Comparação:           [ ] Não iniciado  [ ] Em progresso  [ ] Completo
Fase 4 - Publicação:           [ ] Não iniciado  [ ] Em progresso  [ ] Completo

Progresso geral: ____%

Data última atualização: ___/___/___
```

---

## 🏆 PROJETO COMPLETO!

Quando todos os checkboxes estiverem marcados, você terá:

✅ Infraestrutura WordPress funcionando (ClickOps)
✅ Mesma infraestrutura em Terraform
✅ Comparação objetiva documentada
✅ Código organizado e reutilizável
✅ Material para portfólio
✅ Conhecimento profundo de IaC
✅ Projeto publicado (opcional)
✅ Contribuição para comunidade

**PARABÉNS!** 🎉

Você agora tem experiência prática comprovada em:
- AWS (VPC, EC2, RDS, EFS, ALB, ASG)
- Terraform (módulos, state, providers)
- Infrastructure as Code
- DevOps practices
- Documentação técnica

**Este projeto vale ouro em entrevistas!** 💎

---

## 📝 Notas Pessoais

```
Use este espaço para anotações durante a implementação:

Dificuldades encontradas:
- 
- 
- 

Aprendizados principais:
- 
- 
- 

Melhorias futuras:
- 
- 
- 

Dúvidas para pesquisar:
- 
- 
- 
```

---

**Boa sorte e bom código!** 🚀
