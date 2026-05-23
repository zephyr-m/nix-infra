# Local Infra

Reproducible local Docker platform for web development.

The contract:

- Nix provides the same CLI tools on every machine.
- Docker runs services.
- Traefik is the single local entrypoint on ports 80 and 443.
- Apps join the external Docker network `edge`.
- Apps publish themselves with Traefik labels.
- Domains use `BASE_DOMAIN`; default is `127.0.0.1.sslip.io`, so `/etc/hosts` is not needed.

## First Run

Host prerequisite: Docker daemon must be enabled on the machine. Nix provides the CLI tools for this repo, but the daemon is an OS-level service.

```bash
cd ~/infra
nix --extra-experimental-features nix-command --extra-experimental-features flakes develop
just start-full
```

Open:

```text
https://demo.127.0.0.1.sslip.io
https://traefik.127.0.0.1.sslip.io
```

The first bootstrap creates `.env`, the external Docker network `edge`, and local TLS certificates with `mkcert`.

## Observability

```bash
just obs-up
just urls
```

Open Grafana:

```text
https://grafana.127.0.0.1.sslip.io
```

Default credentials are in `.env`.

## Adding An App

Every app should attach to the external `edge` network and define Traefik labels:

```yaml
services:
  app:
    build: .
    networks:
      - edge
    labels:
      - traefik.enable=true
      - traefik.docker.network=edge
      - traefik.http.routers.myapp.rule=Host(`myapp.${BASE_DOMAIN}`)
      - traefik.http.routers.myapp.entrypoints=websecure
      - traefik.http.routers.myapp.tls=true
      - traefik.http.services.myapp.loadbalancer.server.port=3000

networks:
  edge:
    external: true
```

## Moving To Another Machine

Install/enable Docker at the OS level, then:

```bash
git clone <this-repo> ~/infra
cd ~/infra
nix --extra-experimental-features nix-command --extra-experimental-features flakes develop
just start
```

If both machines use NixOS, keep Docker enablement in your NixOS config, not in this repo, unless you intentionally want this repo to own host configuration too.

If flakes are enabled globally, `nix develop` is enough.

There is an optional NixOS module at `hosts/nixos/docker.nix` with the Docker host settings this platform expects.

## Domain Strategy

Default:

```text
*.127.0.0.1.sslip.io -> 127.0.0.1
```

Permanent custom option:

```text
*.dev.example.com -> 127.0.0.1
```

Then set:

```env
BASE_DOMAIN=dev.example.com
```
