#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -f .env ]; then
  cp .env.example .env
  echo "created .env from .env.example"
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "docker CLI is not available. Run this from 'nix develop'." >&2
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker daemon is not reachable. Start/enable Docker on this machine first." >&2
  exit 1
fi

if ! docker network inspect edge >/dev/null 2>&1; then
  docker network create edge >/dev/null
  echo "created Docker network: edge"
else
  echo "Docker network already exists: edge"
fi

./scripts/certs.sh

echo
echo "bootstrap complete"
echo "next: just up"
