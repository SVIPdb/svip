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
  exit 1
fi

DUMPFILE="$1"
TARGET_DB=${2:-svip_api}

# first, attempt to disconnect everyone
echo "Attempting to disconnect existing users from ${TARGET_DB}..."
psql -U postgres -c "SELECT pid, (SELECT pg_terminate_backend(pid)) as killed from pg_stat_activity WHERE datname = '${TARGET_DB}';"

GENE_COLS="entrez_id, ensembl_gene_id, symbol, sources, uniprot_ids, location, aliases, prev_symbols"

# used to contain gene_id
VARIANT_COLS="id, name, description, biomarker_type, so_hierarchy, soid, sources, so_name, isoform,\
refseq, chromosome, end_pos, hgvs_c, hgvs_p, reference_name, start_pos, alt, ref, hgvs_g, dbsnp_ids,\
myvariant_hg19, mv_info, crawl_status, somatic_status"

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

    # annotate the incoming variants with __symbol, so they can be mapped to new genes that we're inserting
    echo "alter table public.api_variant_temp add column __symbol varchar;"
    echo "update public.api_variant_temp VT set __symbol=(select symbol from public.api_gene_temp where id=VT.gene_id);"

    # copy from the temp gene table into the target gene table, ignoring potential duplicates
    echo "insert into public.api_gene (${GENE_COLS}) \
    select ${GENE_COLS} from public.api_gene_temp on conflict do nothing;"

    # do the same for variants, but this time with the variants' ids included
    echo "insert into public.api_variant (gene_id, ${VARIANT_COLS}) \
    select (select id from public.api_gene where symbol=VT.__symbol) as gene_id, ${VARIANT_COLS} from public.api_variant_temp VT on conflict do nothing;"

    # # copy evidence tables from dump into the db
    pg_restore "${DUMPFILE}" --data-only \
      -t api_environmentalcontext -t api_phenotype -t api_evidence -t api_association -t api_variantinsource

    # remove temp tables
    echo 'drop table public.api_gene_temp; drop table public.api_variant_temp;'

    # and persist the changes
    echo "COMMIT;"

  ) | psql -v ON_ERROR_STOP=1 -U postgres -d "${TARGET_DB}"
)
