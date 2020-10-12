#!/usr/bin/env bash

# deploys whatever's in master to the production hosts + test host and reboots the stack on each

# first, it lints the frontend locally to determine if it can be built on the remotes without errors,
# then does a git pull + submodule update, followed by docker-compose up --build -d on each of the
# following hosts (by default):
# - svip (i.e., svip.nexus.ethz.ch) (public instance #1)
# - sib-svip (i.e., 192.42.198.84) (public instance #2)
# - svip-test (i.e., svip-test.nexus.ethz.ch) (curation instance)

ansible-playbook -i hosts.ini deploy_prod.yml "$@"
