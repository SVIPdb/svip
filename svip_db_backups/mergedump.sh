#!/usr/bin/env bash

# merges a dumpfile's evidence entries with the current contents of the database
#
# specifically, the following tables in the current database are cleared
# (idented entries below are dependent on the parent and are also cleared):
# - api_variantinsource
#   - api_association
#     - api_environmentalcontext
#     - api_phenotype
#     - api_evidence
#
# the result is that all third-party-specific evidence in the database is dumped, but
# general info and SVIP info are preserved.
#
# next, the dumpfile's api_gene and api_variant tables are merged with the current database's
# contents, *BUT* only 
#
# in the final stage, these tables' contents are copied in from the dump into the current db.
#
# NOTE: the current database *must* contain the same variant IDs as the dump, i.e. the current
# database was loaded from a full dump. otherwise, you'll end up with duplicate variants and/or
# evidence entries that can't be associated with a variant.


function die() {
  echo "$1" >&2
  exit -1
}

[ -z "$1" ] && die "Usage: $0 <dumpfile> [target_db=svip_api]"

if [ ! -f "$1" ]; then
  echo "Error: dump file '$1' doesn't exist or was not found"
  exit -1
fi

DUMPFILE="$1"
TARGET_DB=${2:-svip_api}

# first, attempt to disconnect everyone
echo "Attempting to disconnect existing users from ${TARGET_DB}..."
psql -U postgres -c "SELECT pid, (SELECT pg_terminate_backend(pid)) as killed from pg_stat_activity WHERE datname = '${TARGET_DB}';"

# first, we produce a script from the dump that does everything we need
time (
  # emit statements to perform all the operations in one transaction
  # at the end, these are all piped into psql for execution
  (
    echo "BEGIN; "

    # cascade-delete evidence in current db
    echo "delete from api_variantinsource;"

    # insert all genes, variants from dump into temp tables
    pg_restore "${DUMPFILE}" -t api_gene -t api_variant \
      | sed 's/api_variant/api_variant_temp/g;s/api_gene/api_gene_temp/g'

    # copy from the temp tables into the source tables, ignoring potential duplicates
    echo 'insert into public.api_gene select * from public.api_gene_temp on conflict do nothing;' || die "Failed to populate gene table"
    echo 'insert into public.api_variant select * from public.api_variant_temp on conflict do nothing;' || die "Failed to populate variant table"

    # # copy evidence tables from dump into the db
    pg_restore "${DUMPFILE}" --data-only \
      -t api_environmentalcontext -t api_phenotype -t api_evidence -t api_association -t api_variantinsource

    # remove temp tables
    echo 'drop table public.api_gene_temp; drop table public.api_variant_temp;'

    # and finish it all
    echo "COMMIT;" # echo "ROLLBACK;" # echo "COMMIT;"

  ) | psql -v ON_ERROR_STOP=1 -U postgres -d "${TARGET_DB}"
)
