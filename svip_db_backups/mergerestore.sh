#!/bin/bash
# This script is used to merge/restore from a clean harvester dump.
# You can run it on an instance with a working database and dump in a clean
# harvester dump. It will merge the required tables and make shure the 
# relations are the same as before.
# The script is written in a general manner so you can also use it to merge
# database tables in other projects.

function usage {
  echo " --> USAGE $(basename $0) dumpfile"
  exit 1
}

if [ $# -lt 1 ]; then
  usage
fi

DB_USER='postgres'
DB_NAME='svip_api'
DUMP="$1"
SCHEMA='public'
ORIG_SCHEMA='public_orig'

function sql {
  local stmt="$1"
  psql -P pager=off -e -U ${DB_USER} -d ${DB_NAME} -c "${stmt}"
}

function commit {
  sql "commit;"
}

function disconnect_everyone {
  echo " --> Attempting to disconnect existing users from ${DB_NAME}..."
  sql "SELECT pid, (SELECT pg_terminate_backend(pid)) as killed from pg_stat_activity WHERE datname = '${DB_NAME}';"
}

function drop_schema {
  local schema="$1"

  echo " --> Dropping schema ${schema}..."
  sql "DROP SCHEMA IF EXISTS ${schema} CASCADE"
}

function rename_schema {
  local from_name="$1"
  local to_name="$2"

  drop_schema ${to_name}
  echo " --> Renaming schema ${from_name} to ${to_name}..."
  sql "ALTER SCHEMA ${from_name} RENAME TO ${to_name};"
  set_schema_owner ${to_name}
}

function set_schema_owner {
  local schema="$1"

  echo " --> Setting owner of schema ${schema} to ${DB_USER}..."
  sql "ALTER SCHEMA ${schema} OWNER TO ${DB_USER};"
}

function create_schema {
  local schema="$1"

  echo " --> Creating schema ${schema}..."
  sql "CREATE SCHEMA ${schema}"
  set_schema_owner ${schema}
}

function restore {
  local dump_file="$1"
  if [ ! -f ${dump_file} ]; then
    echo " --> ERROR: Dump file ${dump_file} does not exist!"
    exit 1
  fi
  echo " --> Restoring dump ${dump_file}..."
  pg_restore -U ${DB_USER} -j 16 -F c -d ${DB_NAME} ${dump_file}
}

function diff_table {
  local table="$1"
  local orig_table="$2"
  local cols="$3"

  echo " --> Diff ${table}..${orig_table}"
  sql "SELECT ${cols} from ${table} EXCEPT SELECT ${cols} from ${orig_table};"
}

function add_column {
  local table="$1"
  local column="$2"
  local type="$3"

  echo " --> Adding ${column} from ${table}"
  sql "alter table ${table} add column ${column} ${type};"
}

function drop_column {
  local table="$1"
  local column="$2"

  echo " --> Dropping column ${column} from ${table}"
  sql "ALTER TABLE ${table} DROP COLUMN IF EXISTS ${column};"
}

function merge_table {
  local table="${SCHEMA}.${1}"
  local orig_table="${ORIG_SCHEMA}.${1}"
  local related_tables="${SCHEMA}.${2}"
  local unique_cols="${3}"
  local columns="${4}"
  local relations="${5}"

  if [ "${2}" != "" ]; then
    for related_table in $related_tables
    do
      for col in $unique_cols
      do
        add_column "${related_table%%:*}" "__${col%%:*}" "${col#*:}"
        echo " --> Update ${related_table%%:*} set __${col%%:*} from table ${table}..."
        sql "update ${related_table%%:*} RT set __${col%%:*}=(select ${col%%:*} from ${table} where id=RT.${related_table#*:});"
      done
    done
  fi

  echo " --> Merging table ${table} -> ${orig_table}..."

  # If one of the conflict columns is hit update it
  local conflict_cols=''
  for unique_col in $unique_cols
  do
    conflict_cols+="${unique_col%%:*},"
  done
  # Remove last ,
  conflict_cols=${conflict_cols:0:(-1)}
  
  local slct=''
  local additional_cols=''
  for relation in $relations
  do
    local rel_id_col=${relation%%=*}
    local rel_table=$(echo ${relation#*=} | cut -d: -f1)
    local rel_cols=$(echo ${relation#*=} | cut -d: -f2)
    additional_cols+="${rel_id_col},"
    local whr=''
    for rel_col in ${rel_cols//,/ }
    do
      whr+="${rel_col}=TBL.__${rel_col} and "
    done
    # remove the last ' and '
    whr="${whr:0:(-5)}"
    slct+="(select id from ${ORIG_SCHEMA}.${rel_table} where ${whr}) as ${rel_id_col}, "
  done

  local all_cols="${columns}"
  if [ "${additional_cols}" != "" ]; then
    additional_cols=${additional_cols:0:(-1)}
    all_cols="${additional_cols},${all_cols}"
  fi
  
  # Add a temporary constraint for the conflicting columns
  sql "ALTER TABLE ${orig_table} ADD CONSTRAINT temp_constraint UNIQUE (${conflict_cols});"

  local stmt="INSERT INTO ${orig_table} (${all_cols}) SELECT ${slct} ${columns} from ${table} TBL ON CONFLICT (${conflict_cols}) DO UPDATE set "
  for column in ${all_cols//,/ }
  do
    stmt+="${column} = EXCLUDED.${column},"
  done
  # replace the last , with a ;
  stmt="${stmt:0:(-1)};"
  sql "${stmt}"
  
  # Drop the temporary constraint for the conflicting columns
  sql "ALTER TABLE ${orig_table} DROP CONSTRAINT temp_constraint;"
}

function overwrite_table {
  local table="${SCHEMA}.${1}"
  local orig_table="${ORIG_SCHEMA}.${1}"

  echo " --> Overwriting table ${1}..."
  sql "DELETE FROM ${orig_table};"
  sql "INSERT INTO ${orig_table} SELECT * FROM ${table};"
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
#          table:key_field_to_the_related_table1 table:key_field_to_the_related_table2 (can be '' if no related table)
#   unique_cols: the columns that can be used as a unique constratint in this table in the form 
#          col_name:col_type
#   columns: the columns you want to update from the dump (merge) into the schema in the form
#          col1,col2,...
#   relations: the relation to the related table in the form 
#          key_field_to_the_related_table=related_table:unique_colmn_of_related_table1,unique_colmn_of_related_table2,...
merge_table 'api_gene' 'api_variant:gene_id' 'symbol:text' 'entrez_id,ensembl_gene_id,symbol,sources,uniprot_ids,location,aliases,prev_symbols' ''
merge_table 'api_variant' \
'api_variantinsource:variant_id' \
'name:text hgvs_g:text' \
'name,description,biomarker_type,so_hierarchy,soid,sources,so_name,isoform,refseq,chromosome,end_pos,hgvs_c,hgvs_p,reference_name,start_pos,alt,ref,hgvs_g,dbsnp_ids,myvariant_hg19,mv_info,crawl_status,somatic_status' \
'gene_id=api_gene:symbol'
merge_table 'api_variantinsource' '' 'variant_url:text' 'id,variant_url,extras,source_id' 'variant_id=api_variant:name,hgvs_g'

# restore the overwrite table
for table in api_association api_environmentalcontext api_phenotype api_evidence
do
  overwrite_table ${table}
done

rename_schema ${ORIG_SCHEMA} ${SCHEMA}
