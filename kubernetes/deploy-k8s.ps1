# Script de déploiement Kubernetes - Organisation modulaire
# Usage: .\deploy-k8s.ps1

Write-Host "=== Déploiement Kubernetes - Gestion Produits ===" -ForegroundColor Green

# Ordre de déploiement pour les dépendances
$deploymentOrder = @(
    "configmap.yaml",
    "php-app-configmap.yaml", 
    "storage.yaml",
    "mysql-deployment.yaml",
    "mysql-service.yaml",
    "php-deployment.yaml",
    "php-service.yaml"
)

Write-Host "Déploiement des composants..." -ForegroundColor Yellow

foreach ($file in $deploymentOrder) {
    if (Test-Path $file) {
        Write-Host "Déploiement de $file..." -ForegroundColor Cyan
        kubectl apply -f $file
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Erreur lors du déploiement de $file" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "Fichier $file introuvable" -ForegroundColor Red
    }
}

Write-Host "`nVérification du déploiement..." -ForegroundColor Yellow
kubectl get pods
kubectl get services

Write-Host "`nPour accéder à l'application:" -ForegroundColor Green  
Write-Host "kubectl port-forward service/php-app-service 8080:80" -ForegroundColor Yellow
Write-Host "Puis ouvrir: http://localhost:8080" -ForegroundColor Cyan
Write-Host "Login: admin | Mot de passe: password" -ForegroundColor Cyan