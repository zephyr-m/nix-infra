#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

failures=0

check() {
  local name="$1"
  shift

  if "$@" >/dev/null 2>&1; then
    printf "ok   %s\n" "$name"
  else
    printf "fail %s\n" "$name"
    failures=$((failures + 1))
  fi
}

check "docker CLI" command -v docker
check "docker compose" docker compose version
check "Docker daemon" docker info

if docker info >/dev/null 2>&1; then
  check "edge network" docker network inspect edge
fi

echo
./scripts/urls.sh

if [ "$failures" -gt 0 ]; then
  cat <<'EOF'

Fixes:
  - Run this command inside `nix develop` if Docker CLI is missing.
  - Enable/start Docker daemon at the OS level if Docker daemon fails.
  - Run `just bootstrap` if the `edge` network is missing.

NixOS Docker config:
  virtualisation.docker.enable = true;
  users.users.zephyr.extraGroups = [ "docker" ];

Apply it:
  sudo nixos-rebuild switch
  # then log out and back in
EOF
  exit 1
fi
