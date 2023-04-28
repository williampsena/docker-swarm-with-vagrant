#!/bin/bash
set -e

vagrant_ssh="vagrant ssh manager"

$vagrant_ssh -c "docker stack deploy --compose-file /deploy/traefik-docker-compose.yml traefik"
$vagrant_ssh -c "docker stack deploy --compose-file /deploy/cronjob-docker-compose.yml cron"
$vagrant_ssh -c "docker stack deploy --compose-file /deploy/mariadb-docker-compose.yml db"
