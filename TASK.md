# 📝 TASK.md: Backlog de Implementação & Critérios de Aceitação (Fase 4)

> **Projeto:** ToogleMaster (FIAP POS TECH - Tech Challenge Fase 4)  
> **Diretório Oficial:** `C:\Users\oseia\OneDrive\Área de Trabalho\FIAP_MODULO_3`  
> **Referência Arquitetural:** [SPEC.md](file:///C:/Users/oseia/OneDrive/%C3%81rea%20de%20Trabalho/FIAP_MODULO_3/SPEC.md)  
> **Última Atualização:** 18/10/2026

---

## 📦 Épico 0: Planejamento & Governança Spec-Driven (Fase 0)
- [x] **TASK-01:** Diagnóstico completo da arquitetura em `FIAP_MODULO_3` e leitura do edital da Fase 4.
- [x] **TASK-02:** Entrevista arquitetural e definição da stack (New Relic, PagerDuty, Discord, Self-Healing Webhook In-Cluster, Grafana no Ingress).
- [x] **TASK-03:** Arquivamento de segurança da tríade da Fase 3 (`SPEC_FASE3.md`, `TASK_FASE3.md`, `STATUS_FASE3.md`) e geração do novo [SPEC.md](file:///C:/Users/oseia/OneDrive/%C3%81rea%20de%20Trabalho/FIAP_MODULO_3/SPEC.md).
- [x] **TASK-04:** Criação do backlog [TASK.md](file:///C:/Users/oseia/OneDrive/%C3%81rea%20de%20Trabalho/FIAP_MODULO_3/TASK.md) e painel [STATUS.md](file:///C:/Users/oseia/OneDrive/%C3%81rea%20de%20Trabalho/FIAP_MODULO_3/STATUS.md).

---

## ☁️ Épico 1: Ajustes de Infraestrutura (Terragrunt) & Secrets Manager (Fase 1)
*Objetivo: Ajustar a capacidade do EKS para suportar a stack de observabilidade e adicionar o segredo `/tooglemaster/dev/observability` no AWS Secrets Manager + ESO.*

- [x] **TASK-05:** Atualizar [terragrunt.hcl](file:///C:/Users/oseia/OneDrive/%C3%81rea%20de%20Trabalho/FIAP_MODULO_3/fiap_toogle_master_v2/terraform/environments/dev/terragrunt.hcl) aumentando `eks_desired_size = 3` (mantendo `eks_max_size = 4` com `t3.medium`) para acomodar Prometheus, Loki, Grafana e OTel Collector com folga.
- [x] **TASK-06:** Atualizar [terraform/modules/secrets_manager/main.tf](file:///C:/Users/oseia/OneDrive/%C3%81rea%20de%20Trabalho/FIAP_MODULO_3/fiap_toogle_master_v2/terraform/modules/secrets_manager/main.tf) e [outputs.tf](file:///C:/Users/oseia/OneDrive/%C3%81rea%20de%20Trabalho/FIAP_MODULO_3/fiap_toogle_master_v2/terraform/modules/secrets_manager/outputs.tf) criando o segredo `/tooglemaster/dev/observability` (`NEW_RELIC_LICENSE_KEY`, `PAGERDUTY_INTEGRATION_KEY`, `DISCORD_WEBHOOK_URL`) e liberando sua leitura na IAM Policy do External Secrets Operator.
- [x] **TASK-07:** Atualizar [scripts/update_secrets.py](file:///C:/Users/oseia/OneDrive/%C3%81rea%20de%20Trabalho/FIAP_MODULO_3/fiap_toogle_master_v2/scripts/update_secrets.py) e [k8s/overlays/prod/external-secrets.yaml](file:///C:/Users/oseia/OneDrive/%C3%81rea%20de%20Trabalho/FIAP_MODULO_3/fiap_toogle_master_v2/k8s/overlays/prod/external-secrets.yaml) para sincronizar `observability-secret` automaticamente no cluster.
- **Critério de Aceite (DoD):** `terraform fmt -check` e validação dos módulos Terraform concluídos sem erros.

---

## 🔭 Épico 2: Instrumentação OpenTelemetry nos 5 Microsserviços (Fase 2)
*Objetivo: Instrumentar código e Dockerfiles nos 5 repositórios (`FIAP_MODULO_3/*-service` e submódulos em `fiap_toogle_master_v2/services/*`) com OTel SDK, propagação de contexto HTTP/SQS e suporte a Fault Injection (`/chaos/fail`), mantendo 100% dos testes unitários passando.*

- [x] **TASK-08:** Instrumentar [`auth-service`](file:///C:/Users/oseia/OneDrive/%C3%81rea%20de%20Trabalho/FIAP_MODULO_3/auth-service) (Go):
  - Criar `telemetry.go` (OTel TracerProvider, MeterProvider, W3C Propagator e contadores HTTP).
  - Envolver rotas em `main.go` com middleware OTel + métricas e adicionar rota `/chaos/fail` para injeção controlada de erros HTTP 500 na Prova Real.
  - Validar `go test ./...` no repositório.
- [x] **TASK-09:** Instrumentar [`evaluation-service`](file:///C:/Users/oseia/OneDrive/%C3%81rea%20de%20Trabalho/FIAP_MODULO_3/evaluation-service) (Go):
  - Criar `telemetry.go` e configurar `otelhttp.NewTransport` no `HttpClient`.
  - Propagar `ctx` (`r.Context()`) em `evaluationHandler`, `getDecision`, `getCombinedFlagInfo`, `fetchFromServices`, `fetchFlag` e `fetchRule`.
  - Adicionar spans para Redis (`redis.get`, `redis.set`) e injetar `traceparent` nos `MessageAttributes` do SQS em `sqs.go` + rota `/chaos/fail`.
  - Validar `go test ./...` no repositório.
- [x] **TASK-10:** Instrumentar [`flag-service`](file:///C:/Users/oseia/OneDrive/%C3%81rea%20de%20Trabalho/FIAP_MODULO_3/flag-service) e [`targeting-service`](file:///C:/Users/oseia/OneDrive/%C3%81rea%20de%20Trabalho/FIAP_MODULO_3/targeting-service) (Python):
  - Adicionar pacotes OpenTelemetry (`opentelemetry-sdk`, `opentelemetry-exporter-otlp`, `opentelemetry-instrumentation-flask`, `requests`, `psycopg2`, `logging`) nos `requirements.txt`.
  - Criar módulo/inicialização `telemetry.py` chamado no `app.py` (com desativação automática quando em `pytest` ou sem `OTEL_EXPORTER_OTLP_ENDPOINT`) + rota `/chaos/fail`.
  - Validar `pytest` e `flake8`/`black` nos dois repositórios.
- [x] **TASK-11:** Instrumentar [`analytics-service`](file:///C:/Users/oseia/OneDrive/%C3%81rea%20de%20Trabalho/FIAP_MODULO_3/analytics-service) (Python):
  - Adicionar pacotes OpenTelemetry (`sdk`, `exporter-otlp`, `flask`, `botocore`, `logging`) no `requirements.txt`.
  - Extrair o `traceparent` dos `MessageAttributes` das mensagens SQS recebidas em `app.py` e criar span filho (`sqs.process`), garantindo que o `analytics-service` apareça conectado ao `evaluation-service` no Service Map do New Relic.
  - Validar `pytest` no repositório.
- **Critério de Aceite (DoD):** Testes unitários dos 5 microsserviços passando 100% e código sincronizado entre `FIAP_MODULO_3/*-service` e `FIAP_MODULO_3/fiap_toogle_master_v2/services/*`.

---

## 📊 Épico 3: OTel Collector, Prometheus, Loki e Grafana no GitOps (Fase 3)
*Objetivo: Provisionar toda a stack de monitoramento Opensource e o OTel Collector via ArgoCD (Helm/Kustomize) com Dashboard customizado.*

- [ ] **TASK-12:** Criar configuração e manifesto do **OpenTelemetry Collector** (`k8s/base/otel-collector.yaml`):
  - Receivers OTLP (`4317` gRPC e `4318` HTTP).
  - Exporters para **Prometheus** (`:8889/metrics`), **Loki** (`loki/api/v1/push`) e **New Relic** (`https://otlp.nr-data.net` autenticado via `NEW_RELIC_LICENSE_KEY`).
- [ ] **TASK-13:** Adicionar os **Helm Charts de Observabilidade no GitOps (ArgoCD App of Apps)** em [`k8s/argocd/apps/`](file:///C:/Users/oseia/OneDrive/%C3%81rea%20de%20Trabalho/FIAP_MODULO_3/fiap_toogle_master_v2/k8s/argocd/apps):
  - `03-observability-stack.yaml` (provisionando Prometheus, Loki + Promtail e Grafana via Helm Charts no cluster).
  - Configurar exposição do Grafana via NGINX Ingress (`/grafana`) em [k8s/base/ingress.yaml](file:///C:/Users/oseia/OneDrive/%C3%81rea%20de%20Trabalho/FIAP_MODULO_3/fiap_toogle_master_v2/k8s/base/ingress.yaml).
- [ ] **TASK-14:** Criar o **Dashboard Customizado do Grafana** (`k8s/base/grafana-dashboard.yaml`):
  - Painéis de uso de CPU e Memória do cluster/pods;
  - Taxa de requisições (RPS), latência P95 e taxa de erros HTTP 5xx por microsserviço;
  - Painel de logs em tempo real (Loki) integrado no mesmo dashboard.
- [ ] **TASK-15:** Atualizar os 5 manifestos em [`k8s/base/*-service.yaml`](file:///C:/Users/oseia/OneDrive/%C3%81rea%20de%20Trabalho/FIAP_MODULO_3/fiap_toogle_master_v2/k8s/base) e o [`docker-compose.yaml`](file:///C:/Users/oseia/OneDrive/%C3%81rea%20de%20Trabalho/FIAP_MODULO_3/fiap_toogle_master_v2/docker-compose.yaml) injetando `OTEL_EXPORTER_OTLP_ENDPOINT` e `OTEL_SERVICE_NAME`.
- **Critério de Aceite (DoD):** `kubectl kustomize k8s/overlays/prod` validado sem erros e stack local/cloud pronta para receber métricas, logs e traces.

---

## 🚨 Épico 4: Alertas Inteligentes, PagerDuty, ChatOps & Self-Healing (Fase 4)
*Objetivo: Configurar alertas automáticos no Grafana integrados ao PagerDuty, Discord e automação de Self-Healing no Kubernetes.*

- [ ] **TASK-16:** Criar o componente de **Self-Healing In-Cluster** (`k8s/base/self-healing-webhook.yaml`):
  - Micro-serviço webhook leve + `ServiceAccount`, `Role` e `RoleBinding` (RBAC com permissão para `patch`/`get` em `deployments` no namespace `toogle-master`).
  - Ao receber o alerta `firing` do Grafana, executa automaticamente `kubectl rollout restart deployment/<service> -n toogle-master`, registra o log da mitigação e envia notificação de confirmação no Discord.
- [ ] **TASK-17:** Criar também o workflow `.github/workflows/self-healing.yml` (disparado via webhook `repository_dispatch`) para documentar a automação externa via GitHub Actions.
- [ ] **TASK-18:** Provisionar as **Regras de Alerta e Contact Points do Grafana** (`k8s/base/grafana-alerting.yaml`):
  - Regra `ToggleMaster_High_Error_Rate_5xx` (> 5% de erros HTTP 5xx).
  - Contact Points automáticos para **PagerDuty** (Events API v2), **Discord** (ChatOps) e **Self-Healing Webhook**.
- **Critério de Aceite (DoD):** Fluxo de alerta -> incidente PagerDuty -> notificação Discord -> `rollout restart` automático testado e validado.

---

## 📄 Épico 5: Scripts da Prova Real, Roteiro de Vídeo & Relatório PDF (Fase 5)
*Objetivo: Automatizar a demonstração do vídeo de até 25 min e gerar o Relatório Técnico de Entrega.*

- [ ] **TASK-19:** Atualizar `scripts/bootstrap_cluster.ps1` (e `.sh`) e criar o script `scripts/demo_prova_real.ps1` (e `.sh`) que:
  1. Gera tráfego real nos 5 microsserviços para popular o Dashboard do Grafana e o Service Map no New Relic;
  2. Ativa a falha proposital (`POST /chaos/fail?enable=true` no `auth-service` ou `evaluation-service`) e gera requisições com erro 500;
  3. Monitora no terminal o disparo do alerta e o pod sendo reiniciado automaticamente pelo Self-Healing até voltar ao estado saudável.
- [ ] **TASK-20:** Elaborar o documento `RELATORIO_FASE_4.md` (pronto para exportação em `.PDF`) contendo:
  - Identificação, links dos repositórios e do vídeo;
  - Espaço formatado para os 4 prints obrigatórios (Dashboard Grafana, Trace Distribuído + Service Map no New Relic, Notificação no Discord/PagerDuty, Log/Execução do Self-Healing);
  - **Justificativa Técnica Completa:** Arquitetura do OpenTelemetry Collector, comparativo **New Relic vs Datadog** e **PagerDuty vs OpsGenie**;
  - Roteiro passo a passo para gravação do vídeo.
- **Critério de Aceite (DoD):** Todos os itens de avaliação do edital da Fase 4 atendidos e documentados.
