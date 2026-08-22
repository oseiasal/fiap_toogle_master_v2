<#
.SYNOPSIS
    Script de Destruição Limpa e Completa do ToogleMaster (Teardown)
.DESCRIPTION
    1. Remove as Applications e Namespaces do Kubernetes para liberar interfaces e recursos.
    2. Executa o Terragrunt Destroy no ambiente dev (VPC, EKS, RDS, Redis, SQS, DynamoDB).
    3. Opcionalmente destrói os repositórios ECR em shared/ecr.
#>

$ErrorActionPreference = "Continue"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir

Write-Host "==========================================================" -ForegroundColor Red
Write-Host " ⚠️  TOOGLEMASTER - SCRIPT DE DESTRUIÇÃO TOTAL (TEARDOWN)" -ForegroundColor Red
Write-Host "==========================================================" -ForegroundColor Red

# 1. LIMPAR O KUBERNETES
Write-Host "`n🧹 [1/2] Limpando recursos do Kubernetes..." -ForegroundColor Yellow
kubectl delete application toogle-master -n argocd --ignore-not-found --timeout=60s
kubectl delete namespace toogle-master external-secrets argocd --ignore-not-found --timeout=60s

# 2. DESTRUIR INFRAESTRUTURA VIA TERRAGRUNT (DEV)
Write-Host "`n💥 [2/2] Destruindo infraestrutura AWS via Terragrunt (dev)..." -ForegroundColor Yellow
Set-Location "$ProjectRoot\terraform\environments\dev"
terragrunt destroy --auto-approve

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n" -NoNewline
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host " ✅ AMBIENTE DE DESENVOLVIMENTO DESTRUÍDO COM SUCESSO!" -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Green
} else {
    Write-Host "`n❌ Ocorreu um erro durante o terragrunt destroy." -ForegroundColor Red
}

Set-Location "$ProjectRoot"
