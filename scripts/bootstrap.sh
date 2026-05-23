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
  cat >&2 <<'EOF'
Docker daemon is not reachable.

This repo's Nix shell provides the Docker CLI, but the Docker daemon is an OS service.

On NixOS, enable Docker in your system configuration, rebuild, then log out and back in:

  virtualisation.docker.enable = true;
  users.users.<your-user>.extraGroups = [ "docker" ];

Then run:

  sudo nixos-rebuild switch

Quick checks after reboot/relogin:

  systemctl status docker
  docker info
EOF
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
