#!/usr/bin/env bash
USER=$(echo "$(id -u):$(id -g)")

mkdir -p -m 777 /usr/local/share/seqrepo	
docker-compose run --rm -u ${USER} seqrepo 
ln -s /usr/local/share/seqrepo/$(find /usr/local/share/seqrepo -maxdepth 1 -type d | sort | tail -1 | sed -E 's,.*\/,,') /usr/local/share/seqrepo/latest