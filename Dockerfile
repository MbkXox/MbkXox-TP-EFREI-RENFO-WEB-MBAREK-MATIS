# Dockerfile pour l'application PHP
FROM php:8.1-apache

# Installation des extensions PHP nécessaires
RUN docker-php-ext-install pdo pdo_mysql

# Copie des fichiers de l'application
COPY php/www/ /var/www/html/

# Configuration Apache et permissions
RUN chown -R www-data:www-data /var/www/html/ \
    && a2enmod rewrite \
    && mkdir -p /var/www/html/uploads \
    && chmod 777 /var/www/html/uploads

# Exposition du port 80
EXPOSE 80

# Démarrage d'Apache
CMD ["apache2-foreground"]