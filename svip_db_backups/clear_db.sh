#!/usr/bin/env bash

function die() {
  echo "$1" >&2
  exit -1
}

TARGET_DB=${1:-svip_api}

# first, attempt to disconnect everyone
echo "Attempting to disconnect existing users from ${TARGET_DB}..."
psql -U postgres -c "SELECT pid, (SELECT pg_terminate_backend(pid)) as killed from pg_stat_activity WHERE datname = '${TARGET_DB}';"

DROP_OUTPUT=$( dropdb -U postgres ${TARGET_DB} )
if [ $? -ne 0 ]; then
  if [ -z "${DROP_OUTPUT##*does not exist*}" ]; then
    echo "Drop failed b/c database didn't exist, continuing..."
  else
    die "Can't drop DB, presumably because it's in use"
  fi
fi

createdb -U postgres ${TARGET_DB}
