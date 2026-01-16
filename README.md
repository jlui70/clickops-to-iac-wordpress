# WordPress na AWS: ClickOps vs Infrastructure as Code (Terraform)

## 🎯 Sobre Este Projeto

Este projeto demonstra a **transição de infraestrutura manual (ClickOps) para Infrastructure as Code (IaC)** usando Terraform, através da implementação da mesma arquitetura WordPress escalável na AWS.

### Objetivo
Comparar de forma objetiva e prática duas abordagens:
- ☁️ **ClickOps**: Configuração manual via AWS Console
- 🔧 **Terraform**: Automação completa via código

---

## 📚 Documentação

### 🚀 Por Onde Começar?

1. **[RESUMO-EXECUTIVO.md](RESUMO-EXECUTIVO.md)** - Leia primeiro! Visão geral completa
2. **[PLANEJAMENTO.md](PLANEJAMENTO.md)** - Planejamento estratégico e roadmap
3. **[CHECKLIST-COMPLETO.md](CHECKLIST-COMPLETO.md)** - Checklist executável detalhado
4. **[GUIA-RAPIDO.md](GUIA-RAPIDO.md)** - Comandos práticos
5. **[EXEMPLO-MODULO-TERRAFORM.md](EXEMPLO-MODULO-TERRAFORM.md)** - Código Terraform
6. **[COMPARACAO-TEMPLATE.md](COMPARACAO-TEMPLATE.md)** - Template de análise
7. **[INDICE.md](INDICE.md)** - Índice completo

---

## 🏗️ Arquitetura

VPC → Subnets → Security Groups → RDS + EFS → EC2 Auto Scaling → ALB

---

## 📂 Estrutura

```
.
├── clickops/              # Guia ClickOps manual
├── terraform/             # Código IaC
│   ├── modules/          # 7 módulos Terraform
│   └── environments/     # dev/prod
├── ansible/              # Playbook original
├── docs/                 # Documentação adicional
└── *.md                  # Guias e planejamento
```

---

## 🚀 Status

✅ Setup inicial completo
🚧 Próximo: Implementar módulos Terraform

---

## 💰 Custos AWS: ~$2-3/dia

⚠️ **Configure billing alerts e destrua recursos quando não usar!**

---

**Comece agora**: Abra [CHECKLIST-COMPLETO.md](CHECKLIST-COMPLETO.md) e siga os passos!
