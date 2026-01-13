#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "🚀 Starting Deployment Script..."

# 1. Run migrations (required for Aiven)
echo "Running migrations..."
php artisan migrate --force

# 2. Clear and cache config for speed
echo "Caching configuration..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "✅ Deployment script finished. Starting Apache..."

# 3. Start Apache (CRITICAL: this must be the last line)
exec apache2-foreground
