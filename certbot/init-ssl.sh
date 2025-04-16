#!/bin/bash

# exit as soon as any of these commands fail, this prevents starting a database without certificates
set -e

# Set up needed variables
SSL_DIR="/etc/letsencrypt/live/$RAILWAY_TCP_PROXY_DOMAIN"

SSL_SERVER_CRT="$SSL_DIR/fullchain.pem"
SSL_SERVER_KEY="$SSL_DIR/privkey.pem"

POSTGRES_CONF_FILE="$PGDATA/postgresql.conf"
POSTGRES_HBA_FILE="$PGDATA/pg_hba.conf"

sudo certbot certonly -n --agree-tos --standalone --email $CERTBOT_EMAIL --domain $RAILWAY_TCP_PROXY_DOMAIN

sudo chmod 0755 /etc/letsencrypt/{live,archive}

# PostgreSQL configuration, enable ssl and set paths to certificate files
cat >> "$POSTGRES_CONF_FILE" <<EOF
ssl = on
ssl_cert_file = '$SSL_SERVER_CRT'
ssl_key_file = '$SSL_SERVER_KEY'
EOF

# only allow SSL connections
sed -i 's/host all all all/hostssl all all all/' $POSTGRES_HBA_FILE
