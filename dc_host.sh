#!/usr/bin/env bash

case $(hostname) in
  "svip-dev")
    SITE_COMPOSE="-f compose_configs/sites/svip-dev.yml"
    ;;
  "svip-public")
    SITE_COMPOSE="-f compose_configs/sites/sib-svip.yml"
    ;;
  "svip-test")
    SITE_COMPOSE="-f compose_configs/sites/svip-test.yml"
    ;;
  "svip.nexus.ethz.ch")
    SITE_COMPOSE="-f compose_configs/sites/svip.yml"
    ;;
  *)
    SITE_COMPOSE=""
esac

docker-compose -f docker-compose.yml -f compose_configs/prod.yml ${SITE_COMPOSE} "$@"
