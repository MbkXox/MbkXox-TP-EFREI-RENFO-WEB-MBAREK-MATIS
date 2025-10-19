<?php
    // Configuration pour Docker Compose et Kubernetes
    $host = getenv('DB_HOST') ?: "db"; // "db" pour Docker Compose, "mysql-service" pour Kubernetes
    $username = getenv('DB_USER') ?: "root";
    $password = getenv('DB_PASSWORD') ?: "root";
    $db_name = getenv('DB_NAME') ?: "gestion_produits";

    // Connexion avec pdo mysql
    $db = new PDO("mysql:host=$host;dbname=$db_name", $username, $password);
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $db->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
    
?>