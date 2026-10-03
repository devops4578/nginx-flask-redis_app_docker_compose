#!/bin/bash

COMPOSE_BIN=/usr/local/bin/docker-compose
sudo $COMPOSE_BIN pull web   
sudo $COMPOSE_BIN up -d web