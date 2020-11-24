#!/usr/bin/env bash

docker-compose -f docker-compose.yml -f compose_configs/prod.yml -f compose_configs/sites/sib-svip-private.yml "$@"

