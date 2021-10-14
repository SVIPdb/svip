#!/bin/bash

function usage {
  echo "USAGE $(basename $0) dumpfile"
  exit 1
}

if [ $# -lt 1 ]; then
  usage
fi

DB_USER='postgres'
DB_NAME='svip_api'
DUMP="$1"
FROM_SCHEMA='public'
TO_SCHEMA='public_orig'

function sql {
  stmt="$1"
  psql -P pager=off -q -U ${DB_USER} -d ${DB_NAME} -c "${stmt}"
}

function commit {
  sql "commit;"
}

function disconnect_everyone {
  echo "Attempting to disconnect existing users from ${DB_NAME}..."
  sql "SELECT pid, (SELECT pg_terminate_backend(pid)) as killed from pg_stat_activity WHERE datname = '${DB_NAME}';"
}

function drop_schema {
  schema="$1"

  echo "Dropping schema ${schema}..."
  sql "DROP SCHEMA IF EXISTS ${schema} CASCADE"
}

function rename_schema {
  from_name="$1"
  to_name="$2"

  drop_schema ${to_name}
  echo "Renaming schema ${from_name} to ${to_name}..."
  sql "ALTER SCHEMA ${from_name} RENAME TO ${to_name};"
  set_schema_owner ${to_name}
}

function set_schema_owner {
  schema="$1"

  echo "Setting owner of schema ${to_name} to ${DB_USER}..."
  sql "ALTER SCHEMA ${to_name} OWNER TO ${DB_USER};"
}

function create_schema {
  schema="$1"

  echo "Creating schema ${schema}..."
  sql "CREATE SCHEMA ${schema}"
  set_schema_owner ${schema}
}

function restore {
  dump_file="$1"
  if [ ! -f ${dump_file} ]; then
    echo "ERROR: Dump file ${dump_file} does not exist!"
    exit 1
  fi
  echo "Restoring dump ${dump_file}..."
  pg_restore -U ${DB_USER} -j 16 -F c -d ${DB_NAME} ${dump_file}
}

function diff_table {
  table1="$1"
  table2="$2"
  cols="$3"

  echo "Diff ${table1}..${table2}"
  sql "SELECT ${cols} from ${table1} EXCEPT SELECT ${cols} from ${table2};"
}

function merge_table {
  table1="${FROM_SCHEMA}.${1}"
  table2="${TO_SCHEMA}.${1}"

  diff_table ${table1} ${table2} 'id'
  echo "Merging table ${table1} -> ${table2}..."
  sql "INSERT INTO ${table2} (SELECT * from ${table1}) ON CONFLICT DO NOTHING;"
  diff_table ${table1} ${table2} 'id'
}

disconnect_everyone
rename_schema ${FROM_SCHEMA} ${TO_SCHEMA}
create_schema ${FROM_SCHEMA}
restore ${DUMP}

TABLES="\
auth_user \
auth_group_permissions \
auth_user_user_permissions \
api_gene \
api_variant \
api_summarycomment \
api_variantcomment \
api_disease \
api_varantinsvip \
svip_diseaseinsvip \
svip_sample \
svip_submittedvariantbatch \
svip_submittedvariant \
svip_curationrequest \
svip_curationentry \
api_curationassociation \
api_curationevidence \
svip_curationentry_curation_evidences \
svip_curationreview \
svip_variantcuration \
api_historicalcurationentry \
api_historicalvariantinsvip \
api_sibannotation \
"

for table in TABLES
do
  merge_table ${table}
done

rename_schema ${TO_SCHEMA} ${FROM_SCHEMA}
