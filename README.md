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

## ☸️ Kubernetes (EKS)
Os manifestos para implantação no Kubernetes estão na pasta `/k8s`. Eles incluem:
- **Namespace:** `toogle-master`
- **Deployments:** Com limites de recursos e probes de saúde.
- **Services:** ClusterIP para comunicação interna.
- **Ingress:** Nginx Ingress para roteamento externo.
- **HPA:** Escalabilidade automática para `evaluation-service` e `analytics-service`.

### Como Aplicar:
```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/
```

## 🛠️ Detalhes de Implementação
- **Dockerfiles Otimizados:** Utilizam multi-stage builds para reduzir o tamanho das imagens e aumentar a segurança.
- **Resiliência:** Configuração de Readiness e Liveness Probes em todos os serviços.
- **Escalabilidade:** HPAs configurados para lidar com picos de tráfego e processamento de mensagens.
- **LocalStack Support:** Os serviços foram adaptados para aceitar `AWS_ENDPOINT_URL`, permitindo testes completos de SQS/DynamoDB localmente.
