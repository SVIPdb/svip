#!/bin/bash

TARGET_DB="svip_api"
REFERENCE_DUMP="/backups/svip_api_debug_2019-09-11.dump"

echo "Creating reference database from ${REFERENCE_DUMP}"
createdb ${TARGET_DB}
pg_restore -d ${TARGET_DB} ${REFERENCE_DUMP}
