FROM debian:buster

RUN apt-get update && apt-get install -y \
    nginx \
    openssl

# Create SSL certificate
RUN mkdir -p /etc/ssl/private && \
    mkdir -p /etc/ssl/certs && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt \
    -subj "/C=ES/ST=Madrid/L=Madrid/O=42/CN=nakama.42.fr"

# Copy nginx config
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

# nginx runs on port 443 only with SSL
EXPOSE 443

# Start nginx in foreground
CMD ["nginx", "-g", "daemon off;"]