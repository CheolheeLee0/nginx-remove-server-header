FROM nginx:alpine

# Install necessary packages
RUN apk add --no-cache \
    nginx-mod-http-headers-more \
    curl

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy HTML files
COPY html/ /usr/share/nginx/html/

# Load the headers-more module
RUN echo "load_module modules/ngx_http_headers_more_filter_module.so;" > /etc/nginx/modules/headers-more.conf

# Update nginx.conf to include the module
RUN sed -i '1i\load_module modules/ngx_http_headers_more_filter_module.so;' /etc/nginx/nginx.conf

# Create nginx user and set permissions
RUN addgroup -g 101 -S nginx && \
    adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx nginx && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chmod -R 755 /var/log/nginx

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]