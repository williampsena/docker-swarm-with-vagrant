#!/bin/bash

ENV_FILE="$(pwd)/.env"

load_env() {
    export $(sed '/^#/d' $ENV_FILE)
}

[ ! -f $ENV_FILE ] && cp .env.sample .env

load_env

vagrant ssh manager -- -t <<EOF
printf "$MYSQL_PASSWORD" | docker secret create mariadb-pwd -
printf "$PORTAINER_PASSWORD" | docker secret create portainer-pwd -
docker secret ls
EOF
