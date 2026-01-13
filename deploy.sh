#!/usr/bin/env bash

# Run migrations automatically on startup
echo "Running migrations..."
php artisan migrate --force

# Start Apache in the foreground
apache2-foreground
