#!/usr/bin/env bash

API_CONTAINER=$( docker-compose ps | grep api | cut -d ' ' -f1 )
DB_CONTAINER=$( docker-compose ps | grep db | cut -d ' ' -f1 )
DEFAULT_DUMPFILE="/backups/svip_api_2020-02-12.dump"
TARGET_DB="svip_api"

if [ -z "${DB_CONTAINER}" ]; then
    echo "ERROR: can't find database container, aborting"
    exit 1
fi

echo "=> Loading SVIP db from ${DEFAULT_DUMPFILE} into ${DB_CONTAINER}; this may take some time (~8+ minutes)..."
time docker exec -it ${DB_CONTAINER} bash -c "/backups/restoredump.sh ${DEFAULT_DUMPFILE} ${TARGET_DB}"

# run migrations in API container, if present
if [ ! -z "${API_CONTAINER}" ]; then
    echo "=> API container '${API_CONTAINER}' found, migrating..."
    docker exec -it ${API_CONTAINER} '/app/manage.py migrate'
fi
