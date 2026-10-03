#!/bin/bash

COMPOSE_BIN=/usr/local/bin/docker-compose
sudo docker compose pull web   
sudo docker compose up -d web