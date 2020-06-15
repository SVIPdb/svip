#!/bin/bash

# TARGET_DB="svip_api"
# REFERENCE_DUMP="/backups/svip_api_2020-02-12.dump"

# echo "Creating reference database from ${REFERENCE_DUMP}"
# dropdb ${TARGET_DB}
# createdb ${TARGET_DB}
# pg_restore -F c -d ${TARGET_DB} ${REFERENCE_DUMP}

# NOTE: users should manualy populate the database to avoid deadlocks at boot
# you can load it yourself like so: ./svip_db_backups/load_default_dump.sh
