# Intro

This repository offers an example of how to set up a Docker Swarm, commonly known as a "cluster of Docker Engines."

# Why use Vagrant with Docker?

Because Docker deprecated docker-machine a long time ago, we need to utilize Vagrant to prepare this environment for testing.

# Requirements

Docker Swarm nodes with 1GB RAM can be deployed without issue. It depends on what you want to run, but it is feasible to have a Raspberry cluster to support Docker Swarm, which is a lightweight cluster compared to Kubernetes, but with fewer requirements and resources, for example Scheduler, I use a plugin called Swarm CronJob to schedule somethings.

- Login at DockerHub (required to compare image between nodes)
- Docker
- Virtualbox
- Vagrant and 8GB RAM to work without freezing

# Virtualbox settings

To allow virtual to assign IP addresses, create a file called `/etc/vbox/networks.conf`. In the example below, we set a range of `192.168.0.0/16`.

```bash
sudo mkdir -p /etc/vbox
echo "* 192.168.0.0/16" | sudo tee -a /etc/vbox/networks.conf
```

# Host

You need to add a used hosts to your /etc/hosts, because is routed by Traefik.

```text
127.0.0.1       portainer.localhost whoami.localhost adminer.localhost
```

# Time to up virtual machines

```bash
vagrant up
```

# Deploying a sample stack

This stack includes Traefik as an Edge Router and Whoami to listen for simple HTTP requests.


> To run your deployment, you must use a manager node.

First and foremost, you must define the secrets used by services.
If you do not create a password in the `.env` file, the script will use a sample.

```bash
sh scripts/__docker_secrets.sh 
```


```bash
vagrant ssh manager
docker stack deploy --compose-file /deploy/traefik-docker-compose.yml traefik
docker stack deploy --compose-file /deploy/cronjob-docker-compose.yml cron
docker stack deploy --compose-file /deploy/mariadb-docker-compose.yml db
docker stack deploy --compose-file /deploy/portainer-docker-compose.yml portainer
```

# How to scale services?

Docker Swarm does not support auto-scaling, but you can scale manually with the following command:

> The service traefik_whoami can only operate one container per instance, thus the maximum is two.

```bash
# scale down
docker service scale traefik_whoami=1 

# scale up
docker service scale traefik_whoami=2
```

# Troubleshooting

## Vagrant

If something goes wrong during the Docker installation, the Ansible playbook will be invoked. You can run the command below manually.

```bash
vagrant provision manager worker --provision-with docker-install
```

## Docker Swarm

This command provides the current status of your Docker Service (Traefik).

```bash
docker service ls --filter name=traefik
docker service logs traefik_traefik
docker service ps --no-trunc traefik_traefik
```

# It's time to put everything to the test.

So we'll test with curl, but feel free to test with your preferred browser, brother.
You should hit several times to see round robin in action; the hostname will change with each access because access will be distributed across containers.

```bash
curl http://whoami.localhost:9080/
# > Hostname: ???
```

# Docker Images

If you start DockerHub without logging in, you will get the following issue:

> possibly leading to different nodes running different... versions of the image.

This happens because Docker Swarm requires a registry to compare images and may not work with anonymous access.