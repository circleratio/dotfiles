#!/usr/bin/bash
# -*- coding: utf-8 -*-

if [ -f ./docker-compose.yml ]; then
    docker compose down
fi

docker rm -f $(docker ps -aq)

docker image prune -a
docker volume rm $(docker volume ls -qf dangling=true)
docker system prune --volumes

docker system df
