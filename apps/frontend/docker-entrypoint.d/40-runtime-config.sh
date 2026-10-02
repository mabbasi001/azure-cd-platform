#!/bin/sh
set -e

: "${API_URL:=http://localhost:8000/api}"

cat > /usr/share/nginx/html/config.js <<EOF
window._env_ = {
  API_URL: "${API_URL}"
};
EOF
