import csv
import sys
import os
import json
from django.core.management.base import BaseCommand, CommandError
from api.models import Variant, VariantInSVIP, Sample, CurationEntry

import api


APP_DIR = os.path.dirname(api.__file__)
SVIP_VARS_JSON = os.path.join(APP_DIR, "fixtures", "svip_variants.json")


def create_svipvariants(model_variant, model_svip_variant):
    """
    Loads variant info from SVIP mock data file (api/fixtures/svip_variants.json) into the db
    :param model_variant: the variant model
    :param model_svip_variant: the variantinsvip model
    :return: a tuple (succeeded, total) with the number of variants added vs. the total number tried, respectively
    """
    with open(SVIP_VARS_JSON, "r") as fp:
        svip_variants = json.load(fp)

        model_svip_variant.objects.all().delete()

        succeeded, total = (0, len(svip_variants))

        for s in svip_variants:
            try:
                target_variant = model_variant.objects.get(
                    gene__symbol=s['gene_name'],
                    name=s['variant_name'],
                    hgvs_c__endswith=s['HGVScoding'][s['HGVScoding'].index(':')+1:]
                )
                candidate = model_svip_variant(
                    variant=target_variant,
                    data=s
                )
                candidate.save()
                succeeded += 1
            except model_variant.DoesNotExist:
                print(
                    "Couldn't find corresponding variant w/gene and name '%s %s', skipping..." %
                    (s['gene_name'], s['variant_name'])
                )

        return succeeded, total


def create_svip_related(source, target_model):
    """
    Load samples from api/fixtures/<source> and insert them into target_model. Deletes the contents of
    target_model before insertion. The target_model should have a field svip_variant, and source should
    contain a header with entries that have the same names as target_models' fields. source must also
    contain the fields 'gene', 'variant', and 'cds', which are used to link the new entry to an existing
    VariantInSVIP entry.

    :return: a tuple (succeeded, total) with the number of samples added vs. the total number tried, respectively
    """
    with open(os.path.join(APP_DIR, "fixtures", source), "r") as samples_fp:
        reader = csv.DictReader(samples_fp, dialect=csv.excel_tab)
        succeeded, total = (0, 0)

        target_model.objects.all().delete()

        for sample in reader:
            total += 1

            try:
                candidate = target_model(
                    svip_variant=VariantInSVIP.objects.get(
                        variant__gene__symbol=sample['gene'],
                        variant__name=sample['variant'],
                        variant__hgvs_c__endswith=sample['cds']
                    ),
                    **dict((k, v.strip()) for k, v in sample.items() if k not in ('gene', 'variant', 'cds'))
                )
                candidate.save()
                succeeded += 1
            except VariantInSVIP.DoesNotExist:
                print(
                    "Couldn't find corresponding SVIP variant w/gene, name, cds '%s %s %s', skipping..." %
                    (sample['gene'], sample['variant'], sample['cds'])
                )

        return succeeded, total


class Command(BaseCommand):
    help = 'Populates database with SVIP mock variants'

    def handle(self, *args, **options):
        created_count, total = create_svipvariants(Variant, VariantInSVIP)
        self.stdout.write(self.style.SUCCESS('Created %d out of %d SVIP mock variant entries' % (created_count, total)))

        created_count, total = create_svip_related("samples.tsv", Sample)
        self.stdout.write(self.style.SUCCESS('Created %d out of %d SVIP mock samples' % (created_count, total)))

        created_count, total = create_svip_related("curation.tsv", CurationEntry)
        self.stdout.write(self.style.SUCCESS('Created %d out of %d SVIP mock curation entries' % (created_count, total)))
