#!/usr/bin/env bash

function die() {
  echo "$1" >&2
  exit -1
}

[ -z "$1" ] && die "Usage: $0 <dumpfile> [target_db=svip_api_debug]"

if [ ! -f "$1" ]; then
  echo "Error: dump file '$1' doesn't exist or was not found"
  exit -1
fi

TARGET_DB=${2:-svip_api_debug}

# first, attempt to disconnect everyone
echo "Attempting to disconnect existing users from ${TARGET_DB}..."
psql -U postgres -c "SELECT pid, (SELECT pg_terminate_backend(pid)) as killed from pg_stat_activity WHERE datname = '${TARGET_DB}';"

dropdb ${TARGET_DB} || die "Can't drop DB, presumably because it's in use"

createdb ${TARGET_DB}; pg_restore -j 16 -F c -d ${TARGET_DB} $1
