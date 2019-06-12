#!/bin/bash

REFERENCE_DUMP="/backups/svip_api_debug_2019-05-24.dump"

echo "Creating reference database from ${REFERENCE_DUMP}"
createdb svip_api
pg_restore -d svip_api ${REFERENCE_DUMP}
