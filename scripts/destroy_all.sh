#!/usr/bin/env bash
# =====================================================================
# Script de Destruição Limpa e Completa do ToogleMaster (Linux/Bash)
# =====================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "=========================================================="
echo " ⚠️  TOOGLEMASTER - SCRIPT DE DESTRUIÇÃO TOTAL (TEARDOWN)"
echo "=========================================================="

# 1. LIMPAR O KUBERNETES
echo ""
echo "🧹 [1/2] Limpando recursos do Kubernetes..."
kubectl delete application toogle-master -n argocd --ignore-not-found --timeout=60s || true
kubectl delete namespace toogle-master external-secrets argocd --ignore-not-found --timeout=60s || true

# 2. DESTRUIR INFRAESTRUTURA VIA TERRAGRUNT (DEV)
echo ""
echo "💥 [2/2] Destruindo infraestrutura AWS via Terragrunt (dev)..."
cd "$PROJECT_ROOT/terraform/environments/dev"
terragrunt destroy --auto-approve

echo ""
echo "=========================================================="
echo " ✅ AMBIENTE DE DESENVOLVIMENTO DESTRUÍDO COM SUCESSO!"
echo "=========================================================="
