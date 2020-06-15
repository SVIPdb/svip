#!/usr/bin/env bash

echo "=> Loading SVIP db from svip_api_2020-02-12.dump; this may take some time (8+ minutes)..."
time ( docker stop svip_api_1 && docker exec -it svip_db_1 bash -c 'dropdb svip_api; createdb svip_api && pg_restore -F c -d svip_api /backups/svip_api_2020-02-12.dump' )

