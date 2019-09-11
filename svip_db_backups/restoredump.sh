#!/usr/bin/env bash

TARGET_DB=${2:-svip_api_debug}

if [ ! -f "$1" ]; then
  echo "Error: must specify a dump file"
  exit -1
fi

function die() {
  echo "$1" >&2
  exit -1
}

# first, attempt to disconnect everyone
echo "Attempting to disconnect existing users from ${TARGET_DB}..."
psql -U postgres -c "SELECT pid, (SELECT pg_terminate_backend(pid)) as killed from pg_stat_activity WHERE datname = '${TARGET_DB}';"

dropdb ${TARGET_DB} || die "Can't drop DB, presumably because it's in use"

createdb ${TARGET_DB}; pg_restore -F c -d ${TARGET_DB} $1
