# WordPress na AWS: ClickOps vs Infrastructure as Code (Terraform)

> **Demonstração prática da transição de ClickOps para IaC** com Terraform, implementando arquitetura WordPress escalável e altamente disponível na AWS.

[![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4?style=flat-square&logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/Cloud-AWS-FF9900?style=flat-square&logo=amazon-aws)](https://aws.amazon.com/)
[![WordPress](https://img.shields.io/badge/CMS-WordPress-21759B?style=flat-square&logo=wordpress)](https://wordpress.org/)
[![Docker](https://img.shields.io/badge/Container-Docker-2496ED?style=flat-square&logo=docker)](https://www.docker.com/)
[![MySQL](https://img.shields.io/badge/Database-MySQL_8.0-4479A1?style=flat-square&logo=mysql)](https://www.mysql.com/)

---

## 📋 Sobre o Projeto

Este projeto apresenta uma implementação 100% automatizada via Terraform (Infrastructure as Code) de uma arquitetura WordPress escalável e altamente disponível na AWS, demonstrando a evolução e os benefícios da automação de infraestrutura em relação ao processo manual (ClickOps).

Para automatizar toda a infraestrutura, desenvolvi módulos Terraform reutilizáveis organizados por domínio:

🔧 **Terraform** com 7 módulos especializados (Networking, Security Groups, IAM, Database, EFS, Compute, Load Balancing)
🏗️ **VPC** customizada com subnets públicas/privadas em múltiplas AZs
🐳 **Docker + WordPress** com deployment automatizado via user-data
🗄️ **RDS MySQL 8.0** para banco de dados gerenciado
📁 **EFS** para armazenamento compartilhado persistente
⚖️ **Application Load Balancer** com Target Groups e health checks
📈 **Auto Scaling Group** garantindo elasticidade (min: 1, max: 2)

🎯 **Objetivo**: Demonstrar a superioridade do IaC comparado ao ClickOps manual documentado em [clickops-aws-wordpress](https://github.com/jlui70/clickops-aws-wordpress), evidenciando ganhos em tempo (10-15 min vs 45-60 min), reprodutibilidade, versionamento e manutenibilidade.

✅ **Resultado**: Deploy completamente automatizado, versionado e reproduzível com `terraform apply`, incluindo rollback seguro via `terraform destroy`, eliminando erros manuais e acelerando entregas de infraestrutura.

---
### 🔄 ClickOps vs Terraform

| Aspecto | ClickOps (Manual) | Terraform (IaC) |
|---------|-------------------|-----------------|
| **Método** | Console AWS (cliques) | Código declarativo |
| **Tempo de Deploy** | ~45-60 minutos | ~10-15 minutos |
| **Reprodutibilidade** | ❌ Manual, sujeito a erros | ✅ Automatizado e consistente |
| **Documentação** | ❌ Screenshots e anotações | ✅ Código autodocumentado |
| **Versionamento** | ❌ Não versionável | ✅ Git history completo |
| **Rollback** | ❌ Manual e arriscado | ✅ `terraform destroy` |
| **Módulos** | ❌ N/A | ✅ 7 módulos reutilizáveis |

---

## 🚀 Como Usar

### 1. Pré-requisitos

- AWS CLI instalado e configurado
- Terraform >= 1.0
- Credenciais AWS com permissões adequadas

### 2. Clone e Configure

```bash
# Clone o repositório
git clone https://github.com/jlui70/clickops-to-iac-wordpress.git
cd clickops-to-iac-wordpress/

# Configure credenciais AWS
aws configure
```

### 3. Configure Variáveis do Terraform

```bash
cd terraform/
cp terraform.tfvars.example terraform.tfvars
# Edite terraform.tfvars com suas configurações (senha do DB, região, etc)
nano terraform.tfvars
cd ..
```

### 4. Deploy da Infraestrutura

```bash
# Deploy automatizado (~10-15 min)
./deploy.sh
```

O script executará:
- `terraform init` - Inicializa providers
- `terraform validate` - Valida configuração
- `terraform plan` - Mostra o que será criado
- `terraform apply` - Cria a infraestrutura (após sua confirmação)

---
## **Arquitetura**

### 📊 Diagrama da Infraestrutura Terraform (IaC)

![Arquitetura Terraform IaC](./img/arquitetura-terraform-iac.png)

<details>
<summary>📝 Clique para ver o código Mermaid (para editar)</summary>

```mermaid
graph TB
    subgraph "👤 Usuário"
        USER[Internet User]
    end
    
    subgraph "🌐 AWS Region: us-east-1"
        subgraph "🔧 Terraform Modules"
            TF_MAIN[main.tf<br/>Orquestrador]
            TF_NET[Networking Module]
            TF_SG[Security Groups Module]
            TF_IAM[IAM Module]
            TF_DB[Database Module]
            TF_EFS[EFS Module]
            TF_COMP[Compute Module]
            TF_LB[Load Balancing Module]
        end
        
        subgraph "🏗️ VPC 10.0.0.0/16"
            IGW[Internet Gateway]
            
            subgraph "📍 AZ us-east-1a"
                PUB1[Public Subnet<br/>10.0.1.0/24]
                PRIV1[Private Subnet<br/>10.0.11.0/24]
                NAT[NAT Gateway + EIP]
                EC2_1[EC2 Instance 1<br/>t2.micro<br/>Amazon Linux 2]
                EFS_MT1[EFS Mount Target 1]
            end
            
            subgraph "📍 AZ us-east-1b"
                PUB2[Public Subnet<br/>10.0.2.0/24]
                PRIV2[Private Subnet<br/>10.0.12.0/24]
                EC2_2[EC2 Instance 2<br/>t2.micro<br/>Amazon Linux 2]
                EFS_MT2[EFS Mount Target 2]
            end
            
            ALB[Application Load Balancer<br/>Internet-facing]
            TG[Target Group<br/>HTTP:80]
            ASG[Auto Scaling Group<br/>Min:1 Max:2 Desired:2]
            
            subgraph "🔒 Security Groups"
                SG_ALB[ALB-SG<br/>80,443→Internet]
                SG_APP[APP-SG<br/>80,443←ALB]
                SG_DB[DB-SG<br/>3306←APP]
                SG_EFS[EFS-SG<br/>2049←APP]
            end
            
            RDS[(RDS MySQL 8.0.44<br/>db.t3.micro<br/>20GB gp3)]
            EFS[EFS File System<br/>generalPurpose<br/>bursting]
            
            IAM[IAM Role + Profile<br/>SSM Access]
        end
    end
    
    %% Fluxo de Deploy
    TF_MAIN --> TF_NET
    TF_MAIN --> TF_SG
    TF_MAIN --> TF_IAM
    TF_MAIN --> TF_DB
    TF_MAIN --> TF_EFS
    TF_MAIN --> TF_COMP
    TF_MAIN --> TF_LB
    
    %% Conexões de Usuário
    USER -->|HTTP/HTTPS| ALB
    
    %% Networking Flow
    IGW -.->|Route| PUB1
    IGW -.->|Route| PUB2
    NAT -.->|NAT| PRIV1
    NAT -.->|NAT| PRIV2
    
    %% Load Balancer Flow
    ALB -->|Forward| TG
    TG --> EC2_1
    TG --> EC2_2
    ASG -->|Manages| EC2_1
    ASG -->|Manages| EC2_2
    
    %% Application Flow
    EC2_1 -->|MySQL:3306| RDS
    EC2_2 -->|MySQL:3306| RDS
    EC2_1 -->|NFS:2049| EFS_MT1
    EC2_2 -->|NFS:2049| EFS_MT2
    EFS_MT1 -.->|Sync| EFS
    EFS_MT2 -.->|Sync| EFS
    
    %% Security Groups
    SG_ALB -.->|Protect| ALB
    SG_APP -.->|Protect| EC2_1
    SG_APP -.->|Protect| EC2_2
    SG_DB -.->|Protect| RDS
    SG_EFS -.->|Protect| EFS
    
    %% IAM
    IAM -.->|Attached to| EC2_1
    IAM -.->|Attached to| EC2_2
    
    %% Styling
    classDef terraform fill:#7B42BC,stroke:#5C2D91,color:#fff
    classDef aws fill:#FF9900,stroke:#FF6600,color:#000
    classDef compute fill:#EC7211,stroke:#C45500,color:#fff
    classDef storage fill:#3B48CC,stroke:#232F9D,color:#fff
    classDef network fill:#8C4FFF,stroke:#6B3ACC,color:#fff
    classDef security fill:#DD344C,stroke:#B02833,color:#fff
    
    class TF_MAIN,TF_NET,TF_SG,TF_IAM,TF_DB,TF_EFS,TF_COMP,TF_LB terraform
    class EC2_1,EC2_2,ASG compute
    class RDS,EFS,EFS_MT1,EFS_MT2 storage
    class ALB,TG,IGW,NAT network
    class SG_ALB,SG_APP,SG_DB,SG_EFS,IAM security
```

</details>



## 🏗️ Arquitetura a Ser Implementada

### Visão Geral
VPC → Subnets → Security Groups → RDS + EFS → EC2 Auto Scaling → ALB

### 📦 Componentes Provisionados na AWS

#### 1. **Networking**
- **VPC** customizada (10.0.0.0/16) com DNS habilitado
- **2 Subnets públicas** (10.0.1.0/24 e 10.0.2.0/24) em 2 AZs (us-east-1a, us-east-1b)
- **2 Subnets privadas** (10.0.11.0/24 e 10.0.12.0/24) em 2 AZs
- **Internet Gateway** para acesso público
- **1 Elastic IP** para NAT Gateway
- **1 NAT Gateway** (em subnet pública na AZ us-east-1a)
- **Route Tables**:
  - 1 Route Table pública (rota para Internet Gateway)
  - 2 Route Tables privadas (rotas para NAT Gateway)

#### 2. **Security Groups**
- **ApplicationLoadBalancer-SG**: 
  - Ingress: HTTP (80) e HTTPS (443) de 0.0.0.0/0
  - Egress: HTTP (80) e HTTPS (443) para ApplicationServer-SG
- **ApplicationServer-SG**: 
  - Ingress: HTTP (80) e HTTPS (443) do ALB-SG
  - Egress: MySQL (3306) para Database-SG, NFS (2049) para EFS-SG, HTTPS (443) para internet
- **Database-SG**: 
  - Ingress: MySQL (3306) de ApplicationServer-SG
- **EFS-SG**: 
  - Ingress: NFS (2049) de ApplicationServer-SG e de si mesmo
  - Egress: Todo tráfego

#### 3. **Database (RDS)**
- **Engine**: MySQL 8.0.44
- **Instance class**: db.t3.micro
- **Storage**: 20 GB SSD gp3 (com auto scaling até 50 GB)
- **Encryption**: Desabilitado
- **Multi-AZ**: Não (single AZ)
- **Backup**: Desabilitado (retention period = 0)
- **Publicly accessible**: Não
- **DB Subnet Group**: nas 2 subnets privadas
- **Skip final snapshot**: Sim

#### 4. **Storage (EFS)**
- **EFS File System** (Elastic File System)
- **Performance mode**: generalPurpose
- **Throughput mode**: bursting
- **Encryption**: Desabilitado
- **Lifecycle policy**: Transição para IA após 30 dias
- **2 Mount targets**: 1 em cada subnet privada (2 AZs)

#### 5. **Compute (EC2)**
- **Launch Template** com:
  - **AMI**: Amazon Linux 2 (última versão)
  - **Instance type**: t2.micro
  - **Monitoring**: Habilitado
  - **IAM Instance Profile**: Para SSM access
  - **User Data** com instalação automática de:
    - Docker
    - Docker Compose (v2.32.4)
    - NFS utils
    - SSM Agent
    - Montagem automática do EFS em `/mnt/efs/wordpress`
    - Container WordPress via Docker Compose

#### 6. **Load Balancing & Auto Scaling**
- **Application Load Balancer**:
  - Tipo: application
  - Scheme: internet-facing
  - Subnets: 2 públicas
  - HTTP2: Habilitado
  - Deletion protection: Desabilitado
  
- **Target Group**:
  - Protocolo: HTTP porta 80
  - Health check: path `/`, threshold 2/2, interval 30s, timeout 5s
  - Deregistration delay: 30s
  
- **Listener**: HTTP porta 80 (forward para Target Group)

- **Auto Scaling Group**:
  - **Desired capacity**: 2
  - **Min**: 1
  - **Max**: 2
  - **Subnets**: 2 privadas
  - **Health check type**: ELB
  - **Grace period**: 300s (5 minutos)
  - **Métricas habilitadas**: Desired, InService, Min, Max

#### 7. **IAM**
- **IAM Role**: `wordpress-ec2-ssm-role`
  - Trust policy para ec2.amazonaws.com
- **IAM Policy**: `AmazonSSMManagedInstanceCore` (managed AWS policy)
- **Instance Profile**: Para anexar role às instâncias EC2

### 🚀 Fluxo do Deploy

Quando você executa `./deploy.sh`, o script realiza 6 etapas:

1. **Terraform Init**: Inicializa backend e baixa providers
2. **Terraform Validate**: Valida sintaxe e configuração
3. **Terraform Fmt**: Formata código recursivamente
4. **Terraform Plan**: Cria plano de execução (salvo em `tfplan`)
5. **Confirmação Manual**: Aguarda você digitar "sim" para prosseguir
6. **Terraform Apply**: Cria todos os recursos (~10-15 minutos)

Ao final, você receberá:
- URL do WordPress (via ALB)
- IDs de todos os recursos criados
- Arquivo `deployment-info.txt` com resumo completo

### 💰 Detalhamento de Custos (USD/dia)

| Recurso | Custo Estimado | Observações |
|---------|----------------|-------------|
| NAT Gateway | ~$1.00/dia | Componente mais caro |
| ALB | ~$0.50/dia | Load balancer |
| EC2 t2.micro (2x) | Free tier ou ~$0.25/dia | Elegível para free tier |
| RDS t3.micro | Free tier ou ~$0.50/dia | Elegível para free tier |
| EFS | ~$0.10-0.20/dia | Baseado em uso |
| Transferência | Variável | Depende do tráfego |

**Total estimado**: $2-3/dia durante testes

⚠️ **IMPORTANTE**: Configure billing alerts e execute `./destroy.sh` quando não estiver usando!

---
## 🗑️ Destruir Infraestrutura

Para evitar custos AWS contínuos:

```bash
./destroy.sh
```

---

## 📄 Licença

Este projeto é open source e está disponível sob a [MIT License](LICENSE).

---

## 📞 Contato e Suporte

### 🌐 Conecte-se Comigo

- 📹 **YouTube:** [DevOps Project](https://www.youtube.com/@devops-project)
- 💼 **Portfólio:** [devopsproject.com.br](https://devopsproject.com.br/)
- 💻 **GitHub:** [@jlui70](https://github.com/jlui70)

### 🌟 Gostou do Projeto?

Se este projeto foi útil para você:

- ⭐ Dê uma **estrela** nos repositórios
- 🔄 **Compartilhe** com a comunidade
- 📹 **Inscreva-se** no canal do YouTube
- 🤝 **Contribua** com melhorias

---
<p align="center">
  <sub>Construído com ❤️ para demonstração de conceitos Infrastructure as Code</sub>
</p>
