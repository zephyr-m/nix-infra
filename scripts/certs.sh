#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -f .env ]; then
  cp .env.example .env
fi

BASE_DOMAIN="$(grep '^BASE_DOMAIN=' .env | tail -n 1 | cut -d= -f2-)"
BASE_DOMAIN="${BASE_DOMAIN:-127.0.0.1.sslip.io}"

mkdir -p certs

if ! command -v mkcert >/dev/null 2>&1; then
  echo "mkcert is not available. Run this from 'nix develop'." >&2
  exit 1
fi

mkcert -install
mkcert \
  -cert-file certs/local.crt \
  -key-file certs/local.key \
  "*.${BASE_DOMAIN}" \
  "${BASE_DOMAIN}" \
  localhost \
  127.0.0.1

echo "generated local TLS certificate for *.${BASE_DOMAIN}"
