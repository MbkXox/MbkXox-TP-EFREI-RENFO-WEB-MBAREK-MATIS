FROM php:8.2-apache

# Installer les extensions php (mysql, pdo)
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Copier les fichiers de l'application
COPY php/www/ /var/www/html/

# Copier le fichier SQL
COPY database/gestion_produits.sql /opt/gestion_produits.sql

# Mettre les permissions pour le dossier uploads
RUN mkdir -p /var/www/html/uploads && \
    chmod 777 /var/www/html/uploads && \
    chown -R www-data:www-data /var/www/html/uploads

EXPOSE 80