#!/bin/bash
set -e

CONFIG=/data/options.json

export NEKO_SCREEN=$(jq -r '.resolution // "1920x1080@30"' "$CONFIG")
export NEKO_PASSWORD=$(jq -r '.password // "neko"' "$CONFIG")
export NEKO_PASSWORD_ADMIN=$(jq -r '.admin_password // "admin"' "$CONFIG")
export NEKO_EPR="52000-52100"
export NEKO_ICELITE=true
export NEKO_BIND="0.0.0.0:8080"

# Auto-detect external IP for WebRTC NAT traversal
EXT_IP=$(curl -s --connect-timeout 5 https://ifconfig.me 2>/dev/null || true)
if [ -n "$EXT_IP" ]; then
  export NEKO_NAT1TO1="$EXT_IP"
  echo "[neko] External IP detected: $EXT_IP"
fi

echo "[neko] Starting: screen=$NEKO_SCREEN, port=8080, WebRTC=$NEKO_EPR"

# Find supervisord config (neko image uses supervisord)
for conf in /etc/neko/supervisord.conf /etc/supervisord.conf /etc/supervisor/supervisord.conf; do
  if [ -f "$conf" ]; then
    exec /usr/bin/supervisord -c "$conf"
  fi
done

# Fallback: run supervisord without explicit config
exec /usr/bin/supervisord
