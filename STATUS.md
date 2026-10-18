# 📊 STATUS.md: Painel de Acompanhamento & Governança (Fase 4)

> **Projeto:** ToogleMaster (FIAP POS TECH - Tech Challenge Fase 4)  
> **Diretório Oficial:** `C:\Users\oseia\OneDrive\Área de Trabalho\FIAP_MODULO_3`  
> **Objetivo:** Observabilidade Total (Prometheus, Loki, Grafana, OpenTelemetry Collector, New Relic APM) e Resposta Ativa (PagerDuty, Discord ChatOps e Self-Healing no Kubernetes).  
> **Última Atualização:** 18/10/2026  
> **Status Geral:** 🟢 Épicos 0, 1 e 2 Concluídos (55%) | Pronto para Iniciar Épico 3 (OTel Collector, Prometheus, Loki e Grafana no GitOps)

---

## 📈 Painel Geral de Progresso

```text
[███████████░░░░░░░░░] 55% Concluído (Épicos 0, 1 e 2 Finalizados)
```

| Fase / Épico | Descrição | Status | Conclusão |
| :--- | :--- | :---: | :---: |
| **Fase 0** | Diagnóstico As-Is, Entrevista Arquitetural e Tríade `SPEC -> TASK -> STATUS` | 🟢 Concluído | 100% |
| **Fase 1** | Ajustes de Infraestrutura (Terragrunt EKS Scaling) & AWS Secrets Manager (`observability`) | 🟢 Concluído | 100% |
| **Fase 2** | Instrumentação OpenTelemetry nos 5 Microsserviços (Go & Python) + `/chaos/fail` | 🟢 Concluído | 100% |
| **Fase 3** | OTel Collector, Prometheus, Loki e Grafana (Dashboard Customizado) no ArgoCD GitOps | ⚪ Pendente | 0% |
| **Fase 4** | Alertas Inteligentes, PagerDuty, Discord ChatOps & Self-Healing Webhook In-Cluster | ⚪ Pendente | 0% |
| **Fase 5** | Script da Prova Real (`demo_prova_real`), Roteiro de Vídeo & Relatório Final (`RELATORIO_FASE_4.md`) | ⚪ Pendente | 0% |

---

## 📋 Detalhamento das Tarefas (TASKs)

| ID | Épico | Tarefa | Responsável | Status |
| :--- | :--- | :--- | :---: | :---: |
| **TASK-01** | Épico 0 | Diagnóstico da arquitetura em `FIAP_MODULO_3` e leitura do edital da Fase 4 | Antigravity | 🟢 Concluído |
| **TASK-02** | Épico 0 | Alinhamento de decisões arquiteturais (New Relic, PagerDuty, Discord, Self-Healing K8s) | Usuário / Antigravity | 🟢 Concluído |
| **TASK-03** | Épico 0 | Backup da Fase 3 (`*_FASE3.md`) e criação do [SPEC.md](file:///C:/Users/oseia/OneDrive/%C3%81rea%20de%20Trabalho/FIAP_MODULO_3/SPEC.md) da Fase 4 | Antigravity | 🟢 Concluído |
| **TASK-04** | Épico 0 | Criação do [TASK.md](file:///C:/Users/oseia/OneDrive/%C3%81rea%20de%20Trabalho/FIAP_MODULO_3/TASK.md) e [STATUS.md](file:///C:/Users/oseia/OneDrive/%C3%81rea%20de%20Trabalho/FIAP_MODULO_3/STATUS.md) da Fase 4 | Antigravity | 🟢 Concluído |
| **TASK-05** | Épico 1 | Aumentar `eks_desired_size = 3` em `terraform/environments/dev/terragrunt.hcl` | Antigravity | 🟢 Concluído |
| **TASK-06** | Épico 1 | Adicionar segredo `/tooglemaster/dev/observability` no módulo `secrets_manager` | Antigravity | 🟢 Concluído |
| **TASK-07** | Épico 1 | Atualizar `scripts/update_secrets.py` e `k8s/overlays/prod/external-secrets.yaml` | Antigravity | 🟢 Concluído |
| **TASK-08** | Épico 2 | Instrumentar `auth-service` (Go) com OTel SDK + rota `/chaos/fail` + testes | Antigravity | 🟢 Concluído |
| **TASK-09** | Épico 2 | Instrumentar `evaluation-service` (Go) com propagação HTTP/Redis/SQS + `/chaos/fail` + testes | Antigravity | 🟢 Concluído |
| **TASK-10** | Épico 2 | Instrumentar `flag-service` e `targeting-service` (Python) com OTel SDK + testes | Antigravity | 🟢 Concluído |
| **TASK-11** | Épico 2 | Instrumentar `analytics-service` (Python) com extração de `traceparent` do SQS + testes | Antigravity | 🟢 Concluído |
| **TASK-12** | Épico 3 | Criar manifesto e pipeline do OpenTelemetry Collector (`k8s/base/otel-collector.yaml`) | Antigravity | ⚪ Pendente |
| **TASK-13** | Épico 3 | Adicionar Helm Charts (Prometheus, Loki, Grafana) em `k8s/argocd/apps/` + rota `/grafana` no Ingress | Antigravity | ⚪ Pendente |
| **TASK-14** | Épico 3 | Criar Dashboard Customizado do Grafana (`k8s/base/grafana-dashboard.yaml`) | Antigravity | ⚪ Pendente |
| **TASK-15** | Épico 3 | Atualizar ConfigMaps/Deployments em `k8s/base/` e `docker-compose.yaml` com variáveis OTel | Antigravity | ⚪ Pendente |
| **TASK-16** | Épico 4 | Criar `self-healing-webhook` + RBAC Kubernetes (`k8s/base/self-healing-webhook.yaml`) | Antigravity | ⚪ Pendente |
| **TASK-17** | Épico 4 | Criar workflow `.github/workflows/self-healing.yml` (Runbook Automation via webhook) | Antigravity | ⚪ Pendente |
| **TASK-18** | Épico 4 | Provisionar regras de alerta e Contact Points no Grafana (PagerDuty + Discord + Self-Healing) | Antigravity | ⚪ Pendente |
| **TASK-19** | Épico 5 | Criar script `scripts/demo_prova_real.ps1` / `.sh` e atualizar `bootstrap_cluster.ps1` | Antigravity | ⚪ Pendente |
| **TASK-20** | Épico 5 | Elaborar `RELATORIO_FASE_4.md` com Justificativa Técnica e roteiro do vídeo | Antigravity | ⚪ Pendente |
