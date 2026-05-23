#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -f .env ]; then
  cp .env.example .env
fi

BASE_DOMAIN="$(grep '^BASE_DOMAIN=' .env | tail -n 1 | cut -d= -f2-)"
BASE_DOMAIN="${BASE_DOMAIN:-127.0.0.1.sslip.io}"

cat <<EOF
Platform:
  Traefik:    https://traefik.${BASE_DOMAIN}

Demo:
  App:        https://demo.${BASE_DOMAIN}

Observability:
  Grafana:    https://grafana.${BASE_DOMAIN}
  Prometheus: https://prometheus.${BASE_DOMAIN}
  Loki:       https://loki.${BASE_DOMAIN}
EOF
