# ToogleMaster

### Ambiente local

Inicializar os submódulos e subir os containers:
```shell
git submodule update --init --recursive
docker compose up --build -d
./smoke-test.sh
```

---

### Infraestrutura e Bootstrap via GitHub Actions

1. **Provisionar Infra + Bootstrap GitOps:** execute a action **`Terraform & Terragrunt IaC Pipeline`** (`terraform.yml`) com `action: apply` e `bootstrap_gitops: true`.
2. **Apenas Bootstrap do Cluster:** se o EKS já estiver criado, execute a action **`Bootstrap EKS Cluster (Kustomize + ArgoCD App of Apps)`** (`bootstrap-k8s-gitops.yml`).

---

### Infraestrutura na AWS (Manual via Terragrunt)

```shell
# 1. Camada compartilhada (ECR e Secrets Manager)
cd terraform/environments/shared/ecr
terragrunt apply --auto-approve

cd ../secrets_manager
terragrunt apply --auto-approve

# 2. Ambiente dev (VPC, EKS, RDS, Redis, SQS e DynamoDB)
cd ../../dev
terragrunt apply --auto-approve

# 3. Configurar kubeconfig local
aws eks update-kubeconfig --name toogle-cluster --region us-east-1
```

#### Liberar acesso local ao EKS (quando criado via GitHub Actions)
Se o cluster foi criado pelo GitHub Actions e o `kubectl` retornar `You must be logged in to the server`:
```shell
aws eks update-cluster-config --name toogle-cluster --region us-east-1 --access-config authenticationMode=API_AND_CONFIG_MAP

aws eks create-access-entry \
  --cluster-name toogle-cluster \
  --region us-east-1 \
  --principal-arn arn:aws:iam::665303623973:user/terraform \
  --type STANDARD

aws eks associate-access-policy \
  --cluster-name toogle-cluster \
  --region us-east-1 \
  --principal-arn arn:aws:iam::665303623973:user/terraform \
  --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy \
  --access-scope type=cluster
```

---

### Configuração do Cluster e ArgoCD (GitOps)

```shell
# 1. Popular segredos no AWS Secrets Manager
python scripts/update_secrets.py

# 2. Aplicar CRDs e overlay de produção (Kustomize)
kubectl apply --server-side -f k8s/overlays/prod/bundle.yaml
kubectl apply --server-side -k k8s/overlays/prod

# 3. Instalar ArgoCD via Helm e aplicar App of Apps
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm upgrade --install argocd argo/argo-cd --namespace argocd --create-namespace
kubectl apply -f k8s/argocd/root-app.yaml

# 4. Executar seed inicial dos bancos RDS
kubectl apply -f k8s/overlays/prod/db-init-job.yaml
```

---

### Acesso ao ArgoCD e Grafana

```shell
# Senha do admin do ArgoCD
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"

# Port-forward do ArgoCD (https://localhost:8080 - usuário: admin)
kubectl port-forward svc/argocd-server -n argocd 8080:443

# URL pública do Ingress / Grafana (http://<ALB>/grafana - admin/admin)
kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"
```

---

### Remoção (Teardown)

Via script:
```shell
.\scripts\destroy_all.ps1 # Windows
./scripts/destroy_all.sh  # Linux/Mac
```

Ou manualmente passo a passo:
```shell
# 1. Deletar o App of Apps e aplicações filhas no ArgoCD
kubectl delete application tooglemaster-root -n argocd --wait=false

# (Opcional) Se alguma Application travar em Deleting por causa de Sync/Finalizer:
kubectl get applications -n argocd -o name | ForEach-Object {
  kubectl patch $_ -n argocd --type merge -p '{"operation":null,"metadata":{"finalizers":null}}'
  kubectl delete $_ -n argocd --wait=false
}

# 2. Desinstalar ArgoCD e remover os namespaces (libera o LoadBalancer da AWS)
helm uninstall argocd -n argocd
kubectl delete namespace toogle-master external-secrets ingress-nginx argocd --ignore-not-found

# 3. Destruir a infraestrutura do ambiente dev na AWS
cd terraform/environments/dev
terragrunt destroy --auto-approve
```
