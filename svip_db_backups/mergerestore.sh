#!/bin/bash
# This script is used to merge/restore from a clean harvester dump.
# You can run it on an instance with a working database and dump in a clean
# harvester dump. It will merge the required tables and make shure the 
# relations are the same as before.
# The script is written in a general manner so you can also use it to merge
# database tables in other projects.

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
SCHEMA='public'
ORIG_SCHEMA='orig'
UID_FIELD='__uid'
DEBUG=0

stmt_buffer=''
post_stmt_buffer=''

function sql {
  local stmt="$1"
  local post=${2:-0}
  if [ "${stmt:(-1)}" != ';' ]; then
    stmt+=';'
  fi
  if [ $post -eq 1 ]; then
    post_stmt_buffer+="${stmt}\n"
  else
    stmt_buffer+="${stmt}\n"
  fi
}

function sql_now {
  local stmt="$1"
  if [ "${stmt:(-1)}" != ';' ]; then
    stmt+=';'
  fi
  if [ $DEBUG -eq 0 ]; then
    echo "${stmt}" | psql -U ${DB_USER} -d ${DB_NAME}
  else
    echo "${stmt}"
  fi
}

function notice {
  local msg="$1"

  echo " --> ${msg}"
}

function commit {
  stmt_buffer+="COMMIT;\nBEGIN;\n"
}

function disconnect_everyone {
  echo " --> Attempting to disconnect existing users FROM ${DB_NAME}..."
  sql_now "SELECT pid, (SELECT pg_terminate_backend(pid)) AS killed FROM pg_stat_activity WHERE datname = '${DB_NAME}';"
}

function drop_schema {
  local schema="$1"

  echo " --> Dropping schema ${schema}..."
  sql_now "DROP SCHEMA IF EXISTS ${schema} CASCADE"
}

function rename_schema {
  local from_name="$1"
  local to_name="$2"

  drop_schema ${to_name}
  echo " --> Renaming schema ${from_name} to ${to_name}..."
  sql_now "ALTER SCHEMA ${from_name} RENAME TO ${to_name};"
  set_schema_owner ${to_name}
}

function set_schema_owner {
  local schema="$1"

  echo " --> Setting owner of schema ${schema} to ${DB_USER}..."
  sql_now "ALTER SCHEMA ${schema} OWNER TO ${DB_USER};"
}

function create_schema {
  local schema="$1"

  echo " --> Creating schema ${schema}..."
  sql_now "CREATE SCHEMA ${schema}"
  set_schema_owner ${schema}
}

function restore {
  local dump_file="$1"
  if [ ! -f ${dump_file} ]; then
    echo " --> ERROR: Dump file ${dump_file} does not exist!"
    exit 1
  fi
  echo " --> Restoring dump ${dump_file}..."
  if [ $DEBUG -eq 0 ]; then
    pg_restore -U ${DB_USER} -j 16 -F c -d ${DB_NAME} ${dump_file}
  fi
}

function diff_table {
  local table="$1"
  local orig_table="$2"
  local cols="$3"

  echo " --> Diff ${table}..${orig_table}"
  sql_now "SELECT ${cols} FROM ${table} EXCEPT SELECT ${cols} FROM ${orig_table};"
}

function add_column {
  local table="$1"
  local column="$2"
  local type="$3"

  notice "Adding ${column} FROM ${table}"
  sql_now "ALTER TABLE ${table} ADD COLUMN IF NOT EXISTS ${column} ${type};"
}

function later_drop_column {
  local table="$1"
  local column="$2"

  notice "Dropping column ${column} FROM ${table}"
  sql "ALTER TABLE ${table} DROP COLUMN IF EXISTS ${column};" 1
}

function null_replacement {
  col="$1"
  if [ "${col#*:}" == "text" ]; then
    echo "'NULL'"
  else
    echo '-1'
  fi
}

function delete_duplicates {
  local table="$1"

  notice "Delete duplicates from table ${table}, keeping lowest id..."
  sql_now "DELETE FROM ${table} a USING ${table} b WHERE a.id < b.id AND a.${UID_FIELD} = b.${UID_FIELD};"
}

function add_uid {
  local table="$1"
  local unique_cols="$2"

  notice "Create uid in table ${table} FROM unique columns ${unique_cols}"
  add_column "${table}" "${UID_FIELD}" "text"
  sql_now "UPDATE ${table} RT set ${UID_FIELD}=md5(concat(${unique_cols}))"
  delete_duplicates "${table}"
  sql_now "CREATE UNIQUE INDEX IF NOT EXISTS ${table//\./_}_idx_uid ON ${table} (${UID_FIELD});"
  sql "DROP INDEX IF EXISTS ${table//\./_}_idx_uid;" 1
}

function add_uid_relation {
  local schema="$1"
  local table="$2"
  local related_table="$3"
  local reference_field="$4"

  notice "Add relation ${related_table} -> ${table}..."
  add_column "${schema}.${related_table}" "__${reference_field}_uid" "text"
  sql_now "UPDATE ${schema}.${related_table} RT set __${reference_field}_uid=(select ${UID_FIELD} FROM ${schema}.${table} where id=RT.${reference_field});"
  sql_now "CREATE INDEX IF NOT EXISTS ${schema}_idx_${reference_field}_uid ON ${schema}.${related_table} (__${reference_field}_uid);"
  if [ "${schema}" == "${ORIG_SCHEMA}" ]; then
    sql "DROP INDEX IF EXISTS ${schema}.idx_${reference_field}_uid;" 1
    later_drop_column "${schema}.${related_table}" "__${reference_field}_uid"
  fi
}

function prepare_table {
  local table="${SCHEMA}.${1}"
  local orig_table="${ORIG_SCHEMA}.${1}"
  local related_tables="${2}"
  local unique_cols="${3}"

  add_uid "${table}" "${unique_cols}"
  add_uid "${orig_table}" "${unique_cols}"
  later_drop_column "${orig_table}" "${UID_FIELD}"

  # If there are some relations defined generate a reference to the ${UID_FIELD} field
  if [ "${2}" != "" ]; then
    for related_table in $related_tables
    do
      add_uid_relation "${SCHEMA}" "${1}" "${related_table%%:*}" "${related_table#*:}"
      add_uid_relation "${ORIG_SCHEMA}" "${1}" "${related_table%%:*}" "${related_table#*:}"
    done
  fi
}

function merge_table {
  local table="${SCHEMA}.${1}"
  local orig_table="${ORIG_SCHEMA}.${1}"
  local related_tables="${2}"
  local unique_cols="${3}"
  local columns="${4}"
  local relations="${5}"

  notice "Merging table ${table} -> ${orig_table}..."

  prepare_table "${1}" "${related_tables}" "${unique_cols}"

  # add_uid "${table}" "${unique_cols}"
  # add_uid "${orig_table}" "${unique_cols}"
  # later_drop_column "${orig_table}" "${UID_FIELD}"

  # # If there are some relations defined generate a reference to the ${UID_FIELD} field
  # if [ "${2}" != "" ]; then
  #   for related_table in $related_tables
  #   do
  #     add_uid_relation "${SCHEMA}" "${1}" "${related_table%%:*}" "${related_table#*:}"
  #     add_uid_relation "${ORIG_SCHEMA}" "${1}" "${related_table%%:*}" "${related_table#*:}"
  #   done
  # fi

  local slct=''
  local additional_cols=''
  for relation in ${relations//;/ }
  do
    local rel_id_col=${relation%%=*}
    local rel_table=$(echo "${relation#*=}" | cut -d':' -f 1)
    local rel_table_cols=$(echo "${relation#*=}" | cut -d':' -f 2)
    additional_cols+="${rel_id_col},"
    whr="${UID_FIELD} = TBL.__${rel_id_col}_uid"
    slct+="(SELECT id FROM ${ORIG_SCHEMA}.${rel_table} WHERE ${whr}) AS ${rel_id_col}, "
  done

  local all_cols="${columns}"
  if [ "${additional_cols}" != "" ]; then
    additional_cols=${additional_cols%?}
    all_cols="${additional_cols},${all_cols}"
  fi

  # commit
  sql_now "CREATE UNIQUE INDEX IF NOT EXISTS ${orig_table#*.}_temp_constraint ON ${orig_table} (${UID_FIELD});"

  local stmt="INSERT INTO ${orig_table} (${all_cols},${UID_FIELD}) SELECT ${slct} ${columns},${UID_FIELD} FROM ${table} TBL ON CONFLICT (${UID_FIELD}) DO UPDATE set "
  for column in ${all_cols//,/ }
  do
    stmt+="${column} = EXCLUDED.${column},"
  done
  # replace the last , with a ;
  stmt="${stmt%?};"
  sql_now "${stmt}"
  
  sql_now "DROP INDEX ${orig_table}_temp_constraint;"
  notice "Migration done for ${1}"
  # commit
}

function insert_existing {
  local table="${SCHEMA}.${1}"
  local orig_table="${ORIG_SCHEMA}.${1}"
  local relation="${2}"
  local columns="${3}"

  notice "Insert existing table ${table} -> ${orig_table} using reference ${relation}..."

  local relation_parts=(${relation//:/ })
  local reference_table=${relation_parts[0]}
  local reference_field=${relation_parts[1]}
  if [ "${4}" != "" ]; then
    local reference_uid_field="${reference_field}"
  else
    local reference_uid_field="__${reference_field}_uid"
  fi
  local uid_field=${4:-${UID_FIELD}}

  local stmt="INSERT INTO ${orig_table} (${reference_field},${columns}) SELECT (SELECT id FROM ${ORIG_SCHEMA}.${reference_table} WHERE ${uid_field} = tbl.${reference_uid_field}) as ${reference_field}, ${columns} FROM ${table} as tbl WHERE EXISTS (SELECT ${uid_field} FROM ${ORIG_SCHEMA}.${reference_table} AS rt WHERE rt.${uid_field} = tbl.${reference_uid_field})"
  sql_now "${stmt}"
}

function merge_existing {
  local table="${SCHEMA}.${1}"
  local orig_table="${ORIG_SCHEMA}.${1}"
  local unique_cols="${2}"
  local columns="${3},${UID_FIELD}"

  notice "Merge existing table ${table} -> ${orig_table}..."

  local stmt="UPDATE ${orig_table} AS ot SET "
  for column in ${columns//,/ }
  do
    stmt+="${column} = pt.${column},"
  done
  # replace the last , with a space
  stmt="${stmt%?} "
  stmt+="FROM ${table} AS pt WHERE ot.${UID_FIELD} = pt.${UID_FIELD};"

  # local stmt="INSERT INTO ${orig_table} (${columns}) SELECT ${columns} FROM ${table} as tbl WHERE EXISTS (SELECT ${UID_FIELD} FROM ${orig_table} WHERE ${UID_FIELD} = tbl.${UID_FIELD}) ON CONFLICT (${UID_FIELD}) DO UPDATE set "
  # for column in ${columns//,/ }
  # do
  #   stmt+="${column} = EXCLUDED.${column},"
  # done
  # # replace the last , with a ;
  # stmt="${stmt%?};"
  # sql "${stmt}"
}

function clear_table {
  local orig_table="${ORIG_SCHEMA}.${1}"

  notice "Clearing table ${1}..."
  sql_now "DELETE FROM ${orig_table};"
}

function overwrite_table {
  local table="${SCHEMA}.${1}"
  local orig_table="${ORIG_SCHEMA}.${1}"

  notice "Overwriting table ${1}..."
  sql_now "DELETE FROM ${orig_table};"
  sql_now "INSERT INTO ${orig_table} SELECT * FROM ${table};"
}

disconnect_everyone
rename_schema ${SCHEMA} ${ORIG_SCHEMA}
create_schema ${SCHEMA}
restore ${DUMP}

# The following statements MUST be in this order!
overwrite_table 'api_source'

# USAGE of merge_table:
# merge_table table related_tables unique_cols columns relations
#   table: the table you want to merge from the dump into the database in the form
#          table_name
#   related_tables: the tables that are related to this one in the form 
#          table1:key_field_to_the_related_table1,table2:key_field_to_the_related_table2 (can be '' if no related table)
#   unique_cols: the columns that can be used as a unique constratint in this table in the form 
#          col_name:col_type
#   columns: the columns you want to update from the dump (merge) into the schema in the form
#          col1,col2,...
#   relations: the relation to the related table in the form 
#          key_field_to_the_related_table1=related_table1:unique_fields1;key_field_to_the_related_table2=related_table2:unique_fields2
# merge_table 'api_gene' \
#   'api_variant:gene_id' \
#   'symbol' \
#   'entrez_id,ensembl_gene_id,symbol,sources,uniprot_ids,location,aliases,prev_symbols' \
#   ''
prepare_table 'api_gene' \
  'api_variant:gene_id' \
  'symbol'
merge_existing 'api_gene' \
  'symbol' \
  'entrez_id,ensembl_gene_id,symbol,sources,uniprot_ids,location,aliases,prev_symbols'

# it is basically not usefull to have so many unique fields, but in this setup (as long as we do not have a unique hash) its not possible to squice this list.
# merge_table 'api_variant' \
#   'api_variantinsource:variant_id' \
#   '__gene_id_uid,name,hgvs_g,hgvs_c' \
#   'name,description,biomarker_type,so_hierarchy,soid,sources,so_name,isoform,refseq,chromosome,end_pos,hgvs_c,hgvs_p,reference_name,start_pos,alt,ref,hgvs_g,dbsnp_ids,myvariant_hg19,mv_info,crawl_status,somatic_status' \
#   'gene_id=api_gene:symbol'
prepare_table 'api_variant' \
  'api_variantinsource:variant_id' \
  '__gene_id_uid,name,hgvs_g,hgvs_c'
merge_existing 'api_variant' \
  '__gene_id_uid,name,hgvs_g,hgvs_c' \
  'name,description,biomarker_type,so_hierarchy,soid,sources,so_name,isoform,refseq,chromosome,end_pos,hgvs_c,hgvs_p,reference_name,start_pos,alt,ref,hgvs_g,dbsnp_ids,myvariant_hg19,mv_info,crawl_status,somatic_status'

clear_table 'api_variantinsource'
# prepare_table 'api_variantinsource' \
#   'api_association:variant_in_source_id' \
#   'description,drug_labels,variant_name,source_link,clinical_significance,evidence_level,source,source_url,drug_interaction_type,evidence_direction,evidence_type'
insert_existing 'api_variantinsource' \
  'api_variant:variant_id' \
  'id,variant_url,extras,source_id'

clear_table 'api_association'
insert_existing 'api_association' \
  'api_variantinsource:variant_in_source_id' \
  'id, description,drug_labels,variant_name,source_link,clinical_significance,evidence_level,payload,source,source_url,drug_interaction_type,evidence_direction,evidence_type,crawl_status,extras' \
  'id'

clear_table 'api_environmentalcontext'
insert_existing 'api_environmentalcontext' \
  'api_association:association_id' \
  'id, source, term, envcontext_id, usan_stem, description' \
  'id'

clear_table 'api_phenotype'
insert_existing 'api_phenotype' \
  'api_association:association_id' \
  'id, source, term, pheno_id, family, description' \
  'id'

clear_table 'api_evidence'
insert_existing 'api_evidence' \
  'api_association:association_id' \
  'id, publications, "evidenceType_sourceName", "evidenceType_id"' \
  'id'

if [ $DEBUG -eq 1 ]; then
  printf "BEGIN;\n${stmt_buffer}COMMIT;\n"
  printf "BEGIN;\n${post_stmt_buffer}COMMIT;\n"
else
  printf "BEGIN;\n${stmt_buffer}COMMIT;\n" | psql -v ON_ERROR_STOP=1 -P pager=off -e -U ${DB_USER} -d ${DB_NAME}
  printf "BEGIN;\n${post_stmt_buffer}COMMIT;\n" | psql -v ON_ERROR_STOP=1 -P pager=off -e -U ${DB_USER} -d ${DB_NAME}
fi

rename_schema ${SCHEMA} 'import'
rename_schema ${ORIG_SCHEMA} ${SCHEMA}