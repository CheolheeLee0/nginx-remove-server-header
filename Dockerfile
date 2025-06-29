FROM redhat/ubi9:latest

# Install nginx with headers-more module and curl
RUN dnf -y install https://extras.getpagespeed.com/release-latest.rpm && \
    dnf -y install --allowerasing nginx nginx-module-headers-more && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy HTML files
COPY html/ /usr/share/nginx/html/

# Create necessary directories and set permissions
RUN mkdir -p /var/log/nginx /run/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /run/nginx && \
    chmod -R 755 /var/log/nginx

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]