set dotenv-load := true

compose := "docker compose --env-file .env -f compose.yml"
obs := "docker compose --env-file .env --project-directory . -f observability/compose.yml"
demo := "docker compose --env-file .env -f apps/demo/compose.yml"
portal := "docker compose --env-file .env --project-directory . -f portal/compose.yml"

bootstrap:
    ./scripts/bootstrap.sh

certs:
    ./scripts/certs.sh

start:
    just bootstrap
    just up
    just portal-up
    just obs-up
    just demo-up
    just urls

start-full:
    just start

stop:
    just demo-down
    just obs-down
    just portal-down
    just down

up:
    {{compose}} up -d

down:
    {{compose}} down

restart:
    {{compose}} up -d --force-recreate

logs service="traefik":
    {{compose}} logs -f {{service}}

ps:
    {{compose}} ps

obs-up:
    {{obs}} up -d

obs-down:
    {{obs}} down

demo-up:
    {{demo}} up -d --build

demo-down:
    {{demo}} down

portal-up:
    {{portal}} up -d

portal-down:
    {{portal}} down

urls:
    ./scripts/urls.sh

doctor:
    ./scripts/doctor.sh

check:
    docker --version
    docker compose version
    {{compose}} config >/dev/null
    {{portal}} config >/dev/null
    {{obs}} config >/dev/null
    {{demo}} config >/dev/null
