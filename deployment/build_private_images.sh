#!/usr/bin/env bash

# this script builds the SVIP stack, then pushes it to a local registry at port 15000
# you should be running a local registry at that port, e.g. by first executing ./run_registry.sh
# if you want to deploy to the private SVIP instance, remote-forward 15000 when connecting to the instance,
# then use "-f compose_configs/localrepo.yml" when running docker-compose

DOCKER_CMD="docker-compose -f docker-compose.yml -f compose_configs/prod.yml -f compose_configs/sites/sib-svip-private.yml -f compose_configs/localrepo.yml"

# we need to run all this from the SVIP dir so the relative paths work out
cd ..

# first, build the locally-tagged images for the private SVIP instance
# then, push them to our local registry
${DOCKER_CMD} build && ${DOCKER_CMD} push
