#!/usr/bin/env bash
# One-time setup on a fresh Ubuntu 22.04/24.04 Vultr VPS
# Run as root: bash setup-vultr.sh we-events.co.nz joy@we-events.co.nz

set -euo pipefail

DOMAIN="${1:-we-events.co.nz}"
SSL_EMAIL="${2:-admin@${DOMAIN}}"
WEB_ROOT="/var/www/weevent"

echo "==> Updating system..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get upgrade -y -qq

echo "==> Installing nginx and certbot..."
apt-get install -y -qq nginx certbot python3-certbot-nginx ufw

echo "==> Creating web root ${WEB_ROOT}..."
mkdir -p "${WEB_ROOT}"
chown -R www-data:www-data "${WEB_ROOT}"
chmod -R 755 "${WEB_ROOT}"

echo "==> Configuring nginx..."
cat > /etc/nginx/sites-available/weevent <<'NGINX'
server {
    listen 80;
    listen [::]:80;
    server_name we-events.co.nz www.we-events.co.nz;

    root /var/www/weevent;
    index index.html;

    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    location / {
        try_files $uri $uri/ $uri/index.html =404;
    }

    location ~* \.(css|js|svg|png|jpg|jpeg|webp|gif|ico|woff2?)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
        try_files $uri =404;
    }

    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/javascript image/svg+xml application/json;
}
NGINX

ln -sf /etc/nginx/sites-available/weevent /etc/nginx/sites-enabled/weevent
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl enable nginx
systemctl reload nginx

echo "==> Firewall (SSH + HTTP + HTTPS)..."
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw --force enable

echo "==> Placeholder page until first deploy..."
cat > "${WEB_ROOT}/index.html" <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head><meta charset="utf-8"><title>WE Displays</title></head>
<body style="font-family:sans-serif;text-align:center;padding:4rem;">
  <h1>WE EVENTS × WE DISPLAYS</h1>
  <p>Server ready. Run deploy from your PC to publish the site.</p>
</body>
</html>
HTML
chown www-data:www-data "${WEB_ROOT}/index.html"

echo ""
echo "============================================"
echo "  Vultr VPS ready for static site deploy"
echo "============================================"
echo "  Web root: ${WEB_ROOT}"
echo "  Test:     http://$(curl -s ifconfig.me)/"
echo ""
echo "  Next steps:"
echo "  1. Point DNS A records for ${DOMAIN} and www → this server IP"
echo "  2. Run deploy.ps1 from your Windows PC"
echo "  3. After DNS propagates, run SSL:"
echo "     certbot --nginx -d ${DOMAIN} -d www.${DOMAIN} --email ${SSL_EMAIL} --agree-tos --no-eff-email"
echo ""
