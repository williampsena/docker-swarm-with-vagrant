#!/bin/bash
set -e

vagrant up

# You should install your Docker Engine on your server.
# Using this Vagrant setup, Docker will be the default provider for ansible playbooks.

if [! docker info 2>&1 | grep -q 'Is Manager: true']; then 
    vagrant ssh manager -c "docker swarm init"
else
    echo "The Docker Swarm has already started."
fi

swarm_token=$(vagrant ssh manager -c "docker swarm join-token worker -q" | tr -d '\n\r')
printf "$swarm_token" > $(pwd)/.assets/docker-swarm-join-token