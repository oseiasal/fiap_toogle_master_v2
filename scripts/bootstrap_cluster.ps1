<#
.SYNOPSIS
    Script de Bootstrap Automatizado do ToogleMaster
.DESCRIPTION
    1. Popula dinamicamente os segredos no AWS Secrets Manager com as credenciais do RDS, Redis e SQS.
    2. Instala e inicializa o ArgoCD no cluster EKS e aplica a Application GitOps.
    3. Executa o Job de Seed inicial dos 3 bancos de dados PostgreSQL (auth_db, flag_db, targeting_db).
    4. Imprime as credenciais e o comando para abrir o painel web do ArgoCD.
#>

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " 🚀 TOOGLEMASTER - SCRIPT DE BOOTSTRAP END-TO-END (GITOPS)" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# -----------------------------------------------------------------------------
# 1. POPULAR OS SEGREDOS NO AWS SECRETS MANAGER
# -----------------------------------------------------------------------------
Write-Host "`n🔐 [1/3] Populando os 5 Segredos no AWS Secrets Manager..." -ForegroundColor Yellow
python "$ScriptDir\update_secrets.py"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Falha ao atualizar segredos no Secrets Manager." -ForegroundColor Red
    exit 1
}

# -----------------------------------------------------------------------------
# 2. INSTALAR O ARGOCD NO CLUSTER EKS
# -----------------------------------------------------------------------------
Write-Host "`n🌳 [2/3] Instalando e configurando o ArgoCD no Cluster EKS..." -ForegroundColor Yellow

# Cria o namespace argocd se não existir
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Instala os manifestos oficiais do ArgoCD
Write-Host "   -> Baixando e aplicando manifestos do ArgoCD..." -ForegroundColor Gray
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Aguarda o ArgoCD Server estar pronto
Write-Host "   -> Aguardando os serviços do ArgoCD iniciarem..." -ForegroundColor Gray
kubectl rollout status deployment/argocd-server -n argocd --timeout=180s

# Aplica a Application GitOps do ToogleMaster
Write-Host "   -> Conectando o repositório Git ao ArgoCD..." -ForegroundColor Gray
kubectl apply -f "$ProjectRoot\k8s\argocd\argocd-toogletec.yaml"

# -----------------------------------------------------------------------------
# 3. EXECUTAR O SEED DOS BANCOS DE DADOS RDS
# -----------------------------------------------------------------------------
Write-Host "`n🐘 [3/3] Executando o Seed inicial dos bancos de dados RDS..." -ForegroundColor Yellow

# Deleta job anterior se existir e dispara o novo
kubectl delete job db-init-seed-job -n toogle-master --ignore-not-found
kubectl apply -f "$ProjectRoot\k8s\overlays\prod\db-init-job.yaml"

# Aguarda o Job de seed completar
Write-Host "   -> Aguardando conclusão do Seed SQL..." -ForegroundColor Gray
kubectl wait --for=condition=complete job/db-init-seed-job -n toogle-master --timeout=120s

# -----------------------------------------------------------------------------
# 4. RESUMO E ACESSO AO PAINEL
# -----------------------------------------------------------------------------
Write-Host "`n" -NoNewline
Write-Host "==========================================================" -ForegroundColor Green
Write-Host " 🎉 BOOTSTRAP CONCLUÍDO COM SUCESSO TOTAL!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green

# Recupera a senha do ArgoCD
$AdminPassRaw = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>$null
if ($AdminPassRaw) {
    $AdminPassword = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($AdminPassRaw))
} else {
    $AdminPassword = "(Senha já alterada ou secret removido)"
}

Write-Host "`n🌐 INFORMAÇÕES DE ACESSO AO ARGOCD:" -ForegroundColor Cyan
Write-Host "   URL:      https://localhost:8080" -ForegroundColor White
Write-Host "   Usuário:  admin" -ForegroundColor White
Write-Host "   Senha:    $AdminPassword" -ForegroundColor Yellow

Write-Host "`n🚀 Para abrir o painel no navegador, execute em uma nova aba:" -ForegroundColor Cyan
Write-Host "   kubectl port-forward svc/argocd-server -n argocd 8080:443" -ForegroundColor Green
Write-Host "==========================================================`n" -ForegroundColor Green
