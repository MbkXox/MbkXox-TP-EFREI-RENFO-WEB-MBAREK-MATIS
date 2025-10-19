# 🔐 Connexion à l'application - Instructions

## Accès à l'application

**URL :** http://localhost:8080

## Identifiants de connexion

**Login :** `admin`  
**Mot de passe :** `password`

## ✅ Configuration complète

### Base de données
- ✅ Table `utilisateurs` créée avec l'utilisateur admin
- ✅ Table `produits` créée avec les données de test
- ✅ Hash SHA256 du mot de passe configuré correctement

### Application
- ✅ Dossier `uploads` configuré avec permissions 777
- ✅ Variables d'environnement correctement définies
- ✅ Connexion à mysql-service configurée

### Kubernetes
- ✅ 3 réplicas PHP en cours d'exécution  
- ✅ 1 instance MySQL avec données persistantes
- ✅ Services exposés via NodePort
- ✅ ConfigMaps pour configuration centralisée

## 🎯 Test rapide

1. **Ouvrir** http://localhost:8080
2. **Se connecter** avec admin/password  
3. **Vérifier** l'affichage des produits
4. **Tester** l'ajout/modification de produits

## 📊 Vérification du déploiement

```bash
# Vérifier les pods
kubectl get pods

# Vérifier les services  
kubectl get services

# Voir les logs
kubectl logs -l app=php-app
kubectl logs -l app=mysql
```

L'application est maintenant **entièrement fonctionnelle** ! 🚀