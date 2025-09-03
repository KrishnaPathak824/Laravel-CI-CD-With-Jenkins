# -----------------------------
# Stage 1: Composer dependencies
# -----------------------------
FROM composer:2 AS vendor

WORKDIR /app

# Copy composer files
COPY composer.json composer.lock ./

# Install dependencies (no dev for production)
RUN composer install --no-scripts --no-dev --optimize-autoloader --no-interaction --prefer-dist

# -----------------------------
# Stage 2: Production Image
# -----------------------------
FROM php:8.2-fpm-alpine

WORKDIR /var/www/html

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql

# Copy app files
COPY . .

# Copy vendor from stage 1
COPY --from=vendor /app/vendor ./vendor

# Set permissions for Laravel
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 9000
CMD ["php-fpm"]
