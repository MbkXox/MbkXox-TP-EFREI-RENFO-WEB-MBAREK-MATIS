# Guide complet - TP Conteneurisation et Orchestration

## Vue d'ensemble

Ce projet déploie une application web PHP de gestion de produits avec une base de données MySQL en utilisant Docker, Kubernetes et un pipeline CI/CD.

## Architecture

```
Application Web (PHP + Apache) ← → Base de données (MySQL 8.0)
```

## Partie 1 : Docker

### Prérequis
- Docker Desktop installé
- Docker Compose installé

### 1. Construction des images Docker

```bash
# Se placer dans le répertoire du projet
cd "c:\Users\mbare\Desktop\M1-DEV\COURS RENFORCEMENT\tp"

# Construire l'image PHP
docker build -t matismbk/gestion-produits:latest .
```

### 2. Test local avec Docker Compose

```bash
# Démarrer les services
docker compose up -d

# Vérifier les conteneurs
docker compose ps

# Voir les logs
docker compose logs web
docker compose logs db

# Accéder à l'application
# http://localhost:8080
```

### 3. Personnalisation des ports

Modifiez le fichier `.env` :
```env
WEB_PORT=8080
DB_PORT=3306
APP_VERSION=1.0.0
```

### 4. Publication sur Docker Hub

```bash
# Se connecter à Docker Hub
docker login

# Pousser les images
docker push matismbk/gestion-produits:latest
```

### 5. Nettoyage

```bash
# Arrêter les services
docker compose down

# Supprimer les volumes (attention : supprime les données)
docker compose down -v
```

## Partie 2 : Kubernetes avec Minikube

### Structure des fichiers Kubernetes

```
kubernetes/
├── cleanup-k8s.ps1              # Script de nettoyage automatisé
├── configmap.yaml               # Configuration MySQL de base
├── deploy-k8s.ps1               # Script de déploiement automatisé
├── mysql-deployment.yaml        # Déploiement MySQL
├── mysql-initdb-configmap.yaml  # Script d'initialisation de la DB
├── mysql-service.yaml           # Service MySQL (ClusterIP)
├── php-app-configmap.yaml       # Configuration application PHP
├── php-deployment.yaml          # Déploiement PHP (3 réplicas)
├── php-service.yaml             # Service PHP (NodePort 30080)
└── storage.yaml                 # Volumes persistants
```

**Avantages de cette approche modulaire :**
- ✅ **Maintenabilité** : Chaque composant dans un fichier séparé
- ✅ **Réutilisabilité** : Possibilité de déployer seulement certains composants
- ✅ **Lisibilité** : Structure claire et organisée
- ✅ **Debugging** : Plus facile de localiser les problèmes

### Prérequis
- Minikube installé
- kubectl installé

### 1. Démarrage de Minikube

```bash
# Démarrer Minikube
minikube start --driver=docker --memory=4096 --cpus=2

# Vérifier le statut
minikube status

# Configurer kubectl
kubectl cluster-info
```

### 2. Déploiement de l'application

**Option 1 - Script automatisé (Recommandé) :**
```bash
# Se placer dans le répertoire kubernetes
cd kubernetes

# Déployer avec le script automatisé
.\deploy-k8s.ps1
```

**Option 2 - Déploiement manuel :**
```bash
# Déployer fichier par fichier dans l'ordre
kubectl apply -f configmap.yaml
kubectl apply -f php-app-configmap.yaml
kubectl apply -f mysql-initdb-configmap.yaml
kubectl apply -f storage.yaml
kubectl apply -f mysql-deployment.yaml
kubectl apply -f mysql-service.yaml
kubectl apply -f php-deployment.yaml
kubectl apply -f php-service.yaml
```

**Vérification :**
```bash
# Vérifier les déploiements
kubectl get deployments
kubectl get pods
kubectl get services
kubectl get pvc
```

### 3. Mise à l'échelle

```bash
# Scaler l'application PHP à 3 réplicas (déjà configuré)
kubectl scale deployment php-app-deployment --replicas=3

# Vérifier la mise à l'échelle
kubectl get pods -l app=php-app
```

### 4. Accéder à l'application

```bash
# Obtenir l'URL du service
minikube service php-app-service --url

# Ou utiliser le port forwarding
kubectl port-forward service/php-app-service 8080:80
```

### 5. Surveillance et débogage

```bash
# Voir les logs des pods
kubectl logs -l app=php-app
kubectl logs -l app=mysql

# Décrire les ressources
kubectl describe deployment php-app-deployment
kubectl describe service php-app-service

# Exécuter des commandes dans les pods
kubectl exec -it deployment/php-app-deployment -- /bin/bash
```

### 6. Tests de résilience

```bash
# Supprimer un pod pour tester la résilience
kubectl delete pod $(kubectl get pods -l app=php-app -o jsonpath='{.items[0].metadata.name}')

# Vérifier que Kubernetes recrée automatiquement le pod
kubectl get pods -l app=php-app -w
```

## Partie 3 : CI/CD avec GitHub Actions

### Configuration requise

1. **Secrets GitHub à configurer** :
   - `DOCKER_USERNAME` : votre nom d'utilisateur Docker Hub
   - `DOCKER_PASSWORD` : votre mot de passe Docker Hub
   - `KUBE_CONFIG` : configuration kubectl encodée en base64

2. **Obtenir KUBE_CONFIG** :
```bash
# Encoder la configuration kubectl
kubectl config view --raw | base64 -w 0
```

### Pipeline automatique

Le pipeline se déclenche automatiquement sur :
- Push sur la branche `main` ou `develop`
- Pull request vers `main`

**Étapes du pipeline** :
1. **Build** : Construction et publication de l'image Docker
2. **Deploy** : Déploiement sur Kubernetes
3. **Test** : Tests de vérification

### Options pour tester GitHub Actions

#### Option 1 : Mode Test/Simulation (Recommandé)
Utilisez le fichier `ci-cd-test.yml` qui :
- ✅ Build et push l'image Docker
- ✅ Valide la syntaxe des manifests Kubernetes
- ✅ Simule le déploiement sans cluster réel
- ✅ Exécute des tests d'intégration

```bash
# Créer une branche de test
git checkout -b test
git add .
git commit -m "Test CI/CD pipeline"
git push origin test
```

#### Option 2 : Kubernetes en ligne
Services cloud recommandés :
- **DigitalOcean Kubernetes** (DOKS) - 12$/mois
- **Google Kubernetes Engine** (GKE) - Crédit gratuit 300$
- **Azure Kubernetes Service** (AKS) - Crédit gratuit
- **Amazon EKS** - Plus complexe mais puissant

#### Option 3 : Runner auto-hébergé + Minikube local
```bash
# Sur votre machine locale
# 1. Installer GitHub Actions Runner
# 2. Configurer l'accès à votre Minikube
# 3. Le pipeline déploiera sur votre cluster local
```

#### Option 4 : Kind (Kubernetes in Docker)
```bash
# Alternative plus légère que Minikube pour CI/CD
kind create cluster --name test-cluster
```

### Déclenchement manuel

```bash
# Pousser sur main pour déclencher le pipeline
git add .
git commit -m "Deploy application"
git push origin main
```

## Commandes utiles

### Docker
```bash
# Voir les images
docker images

# Supprimer une image
docker rmi matismbk/gestion-produits:latest

# Voir les conteneurs actifs
docker ps

# Nettoyer le système
docker system prune -a
```

### Kubernetes
```bash
# Voir tous les objets
kubectl get all

# Supprimer le déploiement
.\cleanup-k8s.ps1
# Ou manuellement
kubectl delete -f php-service.yaml
kubectl delete -f php-deployment.yaml
kubectl delete -f mysql-service.yaml
kubectl delete -f mysql-deployment.yaml
kubectl delete -f storage.yaml
kubectl delete -f mysql-initdb-configmap.yaml
kubectl delete -f php-app-configmap.yaml
kubectl delete -f configmap.yaml

# Redémarrer un déploiement
kubectl rollout restart deployment/php-app-deployment

# Voir l'historique des déploiements
kubectl rollout history deployment/php-app-deployment
```

### Minikube
```bash
# Dashboard Kubernetes
minikube dashboard

# Arrêter Minikube
minikube stop

# Supprimer le cluster
minikube delete

# Voir les addons disponibles
minikube addons list
```

## Dépannage

### Problèmes courants

1. **Pod en état Pending** :
```bash
kubectl describe pod <nom-du-pod>
# Vérifier les ressources et les PVC
```

2. **Service inaccessible** :
```bash
# Vérifier les endpoints
kubectl get endpoints

# Vérifier les labels
kubectl get pods --show-labels
```

3. **Base de données non accessible** :
```bash
# Tester la connectivité
kubectl exec -it deployment/php-app-deployment -- ping mysql-service
```

### Logs importants

```bash
# Logs de l'application
kubectl logs deployment/php-app-deployment -f

# Logs de MySQL
kubectl logs deployment/mysql-deployment -f

# Événements du cluster
kubectl get events --sort-by='.lastTimestamp'
```

## URLs des images Docker

URLs des images Docker Hub :
- `matismbk/gestion-produits:latest`

## Validation du déploiement

L'application est correctement déployée si :
- 3 réplicas PHP sont en cours d'exécution
- 1 instance MySQL est active
- Le service est accessible via NodePort 30080
- L'application affiche la liste des produits
- Le load balancing fonctionne entre les réplicas#   M b k X o x - T P - E F R E I - R E N F O - W E B - M B A R E K - M A T I S  
 