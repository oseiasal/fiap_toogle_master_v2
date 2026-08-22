# ToogleMaster

### Ambiente local

Para inicializar o projeto com os submódulos instalados:
```shell
git submodule update --init --recursive
```

Em seguida subir os containers com `docker compose up --build -d` e rodar o smoke test para validar os serviços:
```shell
./tests/smoke-test.sh
```

---

### Infraestrutura na AWS (Terraform / Terragrunt)

Para subir a infraestrutura na AWS:
```shell
# 1. Configurar os repositórios no ECR
cd terraform/environments/shared/ecr
terragrunt apply --auto-approve

# 2. Subir VPC, EKS, RDS, Redis, SQS e DynamoDB
cd ../../dev
terragrunt apply --auto-approve

# 3. Atualizar o kubeconfig local para autenticar no cluster EKS
aws eks update-kubeconfig --region us-east-1 --name toogle-cluster

# 4. Subir os pods no namespace
kubectl apply -k ./k8s/overlays/prod/ --server-side
```


---

### Configuração do Cluster e ArgoCD (GitOps)

Para configurar os segredos no Secrets Manager, instalar o ArgoCD e rodar o seed inicial dos bancos RDS:

```shell
# Executar script de bootstrap
.\scripts\bootstrap_cluster.ps1 # ou ./scripts/bootstrap_cluster.sh no Linux/Mac
```

Ou executar manualmente passo a passo:
```shell
# 1. Popular os segredos com as credenciais da AWS
python scripts/update_secrets.py

# 2. Instalar o ArgoCD via Helm
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm upgrade --install argocd argo/argo-cd --namespace argocd --create-namespace


# 3. Conectar a Root Application (App of Apps)
kubectl apply -f k8s/argocd/root-app.yaml


# 4. Executar o seed inicial dos bancos RDS
kubectl apply -f k8s/overlays/prod/db-init-job.yaml
```

---

### Acesso ao ArgoCD

Para pegar a senha de admin e abrir o painel:
```shell
# Pegar a senha do admin
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"

# Abrir o túnel para o navegador (usuário: admin)
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Acessar no navegador em `https://localhost:8080`.