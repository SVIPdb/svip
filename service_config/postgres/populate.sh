#!/bin/bash

TARGET_DB="svip_api"
REFERENCE_DUMP="/backups/svip_api_2020-02-12.dump"

echo "Creating reference database from ${REFERENCE_DUMP}"
dropdb ${TARGET_DB}
createdb ${TARGET_DB}
pg_restore -F c -d ${TARGET_DB} ${REFERENCE_DUMP}
