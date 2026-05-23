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

On NixOS, add Docker to your system config first:

```nix
{
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  users.users.zephyr.extraGroups = [ "docker" ];

  environment.systemPackages = with pkgs; [
    docker
    docker-compose
    just
    mkcert
    openssl
    jq
    yq-go
    curl
    git
  ];
}
```

Then rebuild and log out/back in so the `docker` group is applied:

```bash
sudo nixos-rebuild switch
```

Check that the daemon works:

```bash
systemctl status docker
docker info
```

After that, start the platform:

```bash
cd ~/infra
nix --extra-experimental-features nix-command --extra-experimental-features flakes develop
just start
```

If those tools are installed system-wide, `nix develop` is optional:

```bash
cd ~/infra
just start
```

Open:

```text
https://home.127.0.0.1.sslip.io
https://homepage.127.0.0.1.sslip.io
https://dozzle.127.0.0.1.sslip.io
https://demo.127.0.0.1.sslip.io
https://traefik.127.0.0.1.sslip.io
```

The first bootstrap creates `.env`, the external Docker network `edge`, local TLS certificates with `mkcert`, and writable runtime directories under `data/`.

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

## Platform Portal

The portal is included in `just start`. To run only the portal services manually:

```bash
just portal-up
just urls
```

Open:

```text
https://home.127.0.0.1.sslip.io
https://homepage.127.0.0.1.sslip.io
https://dozzle.127.0.0.1.sslip.io
```

Homepage config lives in `portal/homepage` and is mounted read-only. Runtime logs are mounted separately from `data/homepage/logs` to `/app/config/logs`. The Homepage image is pinned in `.env.example` instead of using `latest`, so config expectations do not change unexpectedly after a pull.

If Homepage fails with a missing config file, add that file explicitly under `portal/homepage` instead of making the whole config directory writable.

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

Install/enable Docker at the OS level first. On NixOS, use the same Docker config shown above.

Then:

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
