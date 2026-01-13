FROM php:8.2-apache

# 1. Install System Dependencies (Includes Postgres driver libpq-dev)
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

# 2. Install PHP Extensions (Includes pdo_pgsql)
RUN docker-php-ext-install pdo_mysql pdo_pgsql mbstring exif pcntl bcmath gd zip

# 3. Enable Apache Rewrite
RUN a2enmod rewrite

# 4. Set Working Directory
WORKDIR /var/www/html

# 5. Copy Application Code
COPY . .

# 6. Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 7. Install PHP Dependencies (CRITICAL STEP)
# We force 'log' driver here to prevent the "Pusher Key" build crash
RUN BROADCAST_CONNECTION=log composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev

# 8. Fix Permissions (Give Apache ownership of everything)
RUN chown -R www-data:www-data /var/www/html

# 9. Configure Apache DocumentRoot
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

# Update the default site config
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf

# Update the main Apache config and EXPLICITLY enable AllowOverride
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf \
    && sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

# 10. Expose Port
EXPOSE 80

