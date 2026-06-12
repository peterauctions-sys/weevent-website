#!/usr/bin/env bash
# Run ON the Vultr server (as root).
# Serves WE Event site on a dedicated port (default 8888) via existing nginx.
#
# Usage:
#   bash install-port.sh
#   bash install-port.sh 8888 /tmp/weevent-release.tar.gz

set -euo pipefail

SITE_PORT="${1:-8888}"
ARCHIVE="${2:-/tmp/weevent-release.tar.gz}"
WEB_ROOT="/var/www/weevent"
NGINX_SITE="/etc/nginx/sites-available/weevent-preview"

echo "==> WE Displays preview install"
echo "    Port: ${SITE_PORT}"
echo "    Root: ${WEB_ROOT}"

if ! command -v nginx >/dev/null 2>&1; then
  echo "nginx not found — installing..."
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq
  apt-get install -y -qq nginx
fi

mkdir -p "${WEB_ROOT}"

if [[ -f "${ARCHIVE}" ]]; then
  echo "==> Extracting ${ARCHIVE} ..."
  rm -rf "${WEB_ROOT:?}"/*
  tar -xzf "${ARCHIVE}" -C "${WEB_ROOT}"
else
  echo "WARN: ${ARCHIVE} not found — keeping existing files in ${WEB_ROOT}"
fi

chown -R www-data:www-data "${WEB_ROOT}" 2>/dev/null || chown -R nginx:nginx "${WEB_ROOT}" 2>/dev/null || true
chmod -R 755 "${WEB_ROOT}"

cat > "${NGINX_SITE}" <<NGINX
server {
    listen ${SITE_PORT};
    listen [::]:${SITE_PORT};
    server_name _;

    root ${WEB_ROOT};
    index index.html;

    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;

    location / {
        try_files \$uri \$uri/ \$uri/index.html =404;
    }

    location ~* \.(css|js|svg|png|jpg|jpeg|webp|gif|ico)$ {
        expires 7d;
        add_header Cache-Control "public";
        try_files \$uri =404;
    }

    gzip on;
    gzip_types text/plain text/css application/javascript image/svg+xml;
}
NGINX

ln -sf "${NGINX_SITE}" /etc/nginx/sites-enabled/weevent-preview
nginx -t
systemctl enable nginx
systemctl reload nginx || systemctl restart nginx

if command -v ufw >/dev/null 2>&1; then
  ufw allow "${SITE_PORT}/tcp" || true
fi

PUBLIC_IP="$(curl -s --max-time 5 ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')"
echo ""
echo "============================================"
echo "  Site ready"
echo "  http://${PUBLIC_IP}:${SITE_PORT}/en/"
echo "  http://${PUBLIC_IP}:${SITE_PORT}/zh/gallery/"
echo "============================================"
