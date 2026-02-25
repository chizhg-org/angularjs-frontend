FROM nginx:alpine

# Remove default static assets
RUN rm -rf /usr/share/nginx/html/*

# Copy our frontend application
COPY index.html /usr/share/nginx/html/

# Add a script to replace the backend URL placeholder at runtime using envsubst
RUN echo '#!/bin/sh' > /docker-entrypoint.d/99-replace-backend-url.sh && 
    echo 'sed -i "s|__BACKEND_URL__|${BACKEND_URL}|g" /usr/share/nginx/html/index.html' >> /docker-entrypoint.d/99-replace-backend-url.sh && 
    chmod +x /docker-entrypoint.d/99-replace-backend-url.sh

# Cloud Run injects $PORT (default 8080)
# Nginx default configuration listens on 80.
# We will create a template that Nginx's entrypoint will process with envsubst
RUN mkdir -p /etc/nginx/templates && 
    echo 'server {' > /etc/nginx/templates/default.conf.template && 
    echo '    listen ${PORT};' >> /etc/nginx/templates/default.conf.template && 
    echo '    server_name localhost;' >> /etc/nginx/templates/default.conf.template && 
    echo '    location / {' >> /etc/nginx/templates/default.conf.template && 
    echo '        root   /usr/share/nginx/html;' >> /etc/nginx/templates/default.conf.template && 
    echo '        index  index.html index.htm;' >> /etc/nginx/templates/default.conf.template && 
    echo '    }' >> /etc/nginx/templates/default.conf.template && 
    echo '}' >> /etc/nginx/templates/default.conf.template

# Ensure the PORT variable defaults to 8080 so local testing works
ENV PORT=8080
ENV BACKEND_URL="http://localhost:8080"

EXPOSE 8080
