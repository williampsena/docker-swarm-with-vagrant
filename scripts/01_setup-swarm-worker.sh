#!/bin/bash
vagrant up

swarm_token=$(vagrant ssh manager -- -t docker swarm join-token manager -q | tr -d '\n\r')

vagrant ssh worker -- -t docker swarm join --token $swarm_token 192.168.0.100:2377