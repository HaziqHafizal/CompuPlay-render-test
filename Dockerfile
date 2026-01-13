FROM php:8.2-apache

# 1. Install System Dependencies (Added libpq-dev for Postgres)
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libpq-dev \
    zip \
    unzip \
    git \
    curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Install PHP Extensions (Added pdo_pgsql)
RUN docker-php-ext-install pdo_mysql pdo_pgsql mbstring exif pcntl bcmath gd zip

# 3. Enable Apache Rewrite
RUN a2enmod rewrite

# 4. Set Working Directory
WORKDIR /var/www/html

# 5. Copy Application Files
COPY . .

# 6. Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 7. Install Dependencies (Include --no-dev for production)
RUN composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev

# 8. Set Permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# 9. Configure Apache (Improved)
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf
# Ensure .htaccess is allowed
RUN sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

# 10. Startup Script
COPY deploy.sh /usr/local/bin/deploy.sh
RUN chmod +x /usr/local/bin/deploy.sh

EXPOSE 80

CMD ["/usr/local/bin/deploy.sh"]
