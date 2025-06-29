FROM ubuntu:latest

# Install nginx-extras and curl
RUN apt-get update && \
    apt-get install -y nginx-extras curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy HTML files
COPY html/ /var/www/html/

# Create necessary directories and set permissions
RUN mkdir -p /var/log/nginx && \
    chown -R www-data:www-data /var/log/nginx && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/log/nginx

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]