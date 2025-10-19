# Script de nettoyage Kubernetes
# Usage: .\cleanup-k8s.ps1

Write-Host "=== Nettoyage Kubernetes - Gestion Produits ===" -ForegroundColor Red

$resources = @(
    "php-service.yaml",
    "php-deployment.yaml", 
    "mysql-service.yaml",
    "mysql-deployment.yaml",
    "storage.yaml",
    "php-app-configmap.yaml",
    "configmap.yaml"
)

Write-Host "Suppression des ressources..." -ForegroundColor Yellow

foreach ($file in $resources) {
    if (Test-Path $file) {
        Write-Host "Suppression de $file..." -ForegroundColor Cyan
        kubectl delete -f $file --ignore-not-found=true
    }
}

Write-Host "`nVérification du nettoyage..." -ForegroundColor Yellow
kubectl get all
kubectl get pvc
kubectl get configmaps

Write-Host "`nNettoyage terminé!" -ForegroundColor Green