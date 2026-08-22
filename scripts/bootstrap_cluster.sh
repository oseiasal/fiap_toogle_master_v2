#!/usr/bin/env bash
# =====================================================================
# Script de Bootstrap Automatizado do ToogleMaster (Linux/macOS/Bash)
# =====================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "=========================================================="
echo " 🚀 TOOGLEMASTER - SCRIPT DE BOOTSTRAP END-TO-END (GITOPS)"
echo "=========================================================="

# 1. POPULAR OS SEGREDOS NO AWS SECRETS MANAGER
echo ""
echo "🔐 [1/3] Populando os 5 Segredos no AWS Secrets Manager..."
python3 "$SCRIPT_DIR/update_secrets.py"

# 2. INSTALAR O ARGOCD NO CLUSTER EKS VIA HELM
echo ""
echo "🌳 [2/3] Instalando e configurando o ArgoCD no Cluster EKS via Helm..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm upgrade --install argocd argo/argo-cd --namespace argocd --create-namespace


echo "   -> Aguardando os serviços do ArgoCD iniciarem..."
kubectl rollout status deployment/argocd-server -n argocd --timeout=180s

echo "   -> Conectando a Root Application (App of Apps) ao ArgoCD..."
kubectl apply -f "$PROJECT_ROOT/k8s/argocd/root-app.yaml"


# 3. EXECUTAR O SEED DOS BANCOS DE DADOS RDS
echo ""
echo "🐘 [3/3] Executando o Seed inicial dos bancos de dados RDS..."
kubectl delete job db-init-seed-job -n toogle-master --ignore-not-found
kubectl apply -f "$PROJECT_ROOT/k8s/overlays/prod/db-init-job.yaml"

echo "   -> Aguardando conclusão do Seed SQL..."
kubectl wait --for=condition=complete job/db-init-seed-job -n toogle-master --timeout=120s

# 4. RESUMO E ACESSO AO PAINEL
echo ""
echo "=========================================================="
echo " 🎉 BOOTSTRAP CONCLUÍDO COM SUCESSO TOTAL!"
echo "=========================================================="

ADMIN_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 --decode || echo "(Senha já alterada)")

echo ""
echo "🌐 INFORMAÇÕES DE ACESSO AO ARGOCD:"
echo "   URL:      https://localhost:8080"
echo "   Usuário:  admin"
echo "   Senha:    $ADMIN_PASS"
echo ""
echo "🚀 Para abrir o painel no navegador, execute em uma nova aba:"
echo "   kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "=========================================================="
