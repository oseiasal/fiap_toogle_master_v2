# ToogleMaster - Fase 2

Este projeto é a evolução do ToggleMaster para uma arquitetura de microsserviços distribuídos, desenvolvida para o Tech Challenge Fase 2.

## 🚀 Como Rodar Localmente

### 1. Aplicar Patches e Preparar Ambiente
Os microsserviços são submódulos. Aplique as customizações necessárias:
```bash
./install.sh
```

### 2. Subir o Ecossistema com Docker Compose
O `docker-compose.yaml` foi configurado para subir todos os 5 microsserviços e as dependências locais:
- **2 instâncias PostgreSQL** (Auth e Main)
- **Redis**
- **DynamoDB Local**
- **LocalStack** (para SQS)
- **AWS Setup** (criação automática de filas e tabelas locais)

Execute:
```bash
docker compose up --build
```

### 3. Verificar Saúde dos Serviços
Após o build e inicialização, execute o smoke test:
```bash
./smoke-test.sh
```

## 📦 Estrutura de Microsserviços
- **auth-service (Go):** Gerencia chaves de API. (Porta 8001)
- **flag-service (Python):** CRUD de feature flags. (Porta 8002)
- **targeting-service (Python):** Regras de segmentação. (Porta 8003)
- **evaluation-service (Go):** "Hot path" de alta performance. (Porta 8004)
- **analytics-service (Python):** Processador de eventos assíncronos. (Porta 8005)

## ☁️ Infraestrutura AWS (Cloud)

O projeto agora suporta o provisionamento automatizado da infraestrutura na AWS (RDS, ECR, SQS, DynamoDB, Redis e EKS) utilizando **Terraform**. Você tem dois caminhos para subir o ambiente:

### Opção 1: Script Automatizado (Recomendado)
Para uma experiência de "um clique" que provisiona a infraestrutura, faz o build das imagens, popula o banco de dados e configura os manifestos Kubernetes:

```bash
chmod +x setup-cloud.sh
./setup-cloud.sh
```
*Este script automatiza o Terraform + Build/Push + Seeding + Patching do K8s.*

### Opção 2: Terraform Manual (IaC)
Se preferir gerenciar os recursos manualmente:

1. Acesse a pasta: `cd terraform`
2. Configure suas variáveis no arquivo `terraform.tfvars` (use o `.example` como base).
3. Execute os comandos:
```bash
terraform init
terraform plan
terraform apply
```

## ☸️ Kubernetes (EKS)
Os manifestos para implantação no Kubernetes estão na pasta `/k8s`. Eles incluem:
- **Namespace:** `toogle-master`
- **Deployments:** Com limites de recursos e probes de saúde.
- **Services:** ClusterIP para comunicação interna.
- **Ingress:** Nginx Ingress para roteamento externo.
- **HPA:** Escalabilidade automática para `evaluation-service` e `analytics-service`.

### Como Aplicar (Kubernetes Estático):
```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/
# Ingress controller que criará um endpoint através de um loadbalancer
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/aws/deploy.yaml
```

### Como Aplicar (Helm):
O projeto agora inclui um **Helm Chart** em `k8s/charts/toogle-master` para facilitar o deploy e a configuração.

1. Instale o chart:
```bash
helm install toogle-master ./k8s/charts/toogle-master -n toogle-master --create-namespace
```

2. Atualize configurações (como AccountID da AWS) via `values.yaml`:
```bash
helm upgrade toogle-master ./k8s/charts/toogle-master -n toogle-master --set accountID="SEU_ID_AWS"
```

## 🛠️ Detalhes de Implementação
- **Dockerfiles Otimizados:** Utilizam multi-stage builds para reduzir o tamanho das imagens e aumentar a segurança.
- **Resiliência:** Configuração de Readiness e Liveness Probes em todos os serviços.
- **Escalabilidade:** HPAs configurados para lidar com picos de tráfego e processamento de mensagens.
- **LocalStack Support:** Os serviços foram adaptados para aceitar `AWS_ENDPOINT_URL`, permitindo testes completos de SQS/DynamoDB localmente.
