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
  "svip-sensa-sec.novalocal")
    SITE_COMPOSE="-f compose_configs/sites/sib-svip-private.yml"
    ;;
  "svip-api.nexus.ethz.ch")
    SITE_COMPOSE="-f compose_configs/sites/svip-api.yml"
    ;;
  "escat.nexus.ethz.ch")
    SITE_COMPOSE="-f compose_configs/sites/escat.yml"
    ;;
  *)
    SITE_COMPOSE=""
esac

docker-compose -f docker-compose.yml -f compose_configs/prod.yml ${SITE_COMPOSE} "$@"
