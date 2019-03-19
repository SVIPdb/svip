import sys
import json
from django.core.management.base import BaseCommand, CommandError
from api.models import Variant, SVIPVariant


def create_svipvariants(model_variant, model_svip_variant):
    # loads variant info from SVIP mock data file into the db
    with open("./api/static/svip_variants.json") as fp:
        svip_variants = json.load(fp)

        model_svip_variant.objects.all().delete()

        succeeded, total = (0, len(svip_variants))

        for s in svip_variants:
            try:
                target_variant = model_variant.objects.get(
                    gene__symbol=s['gene_name'],
                    name=s['variant_name']
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


class Command(BaseCommand):
    help = 'Populates database with SVIP mock variants'

    def handle(self, *args, **options):
        created_count, total = create_svipvariants(Variant, SVIPVariant)
        self.stdout.write(self.style.SUCCESS('Created %d out of %d SVIP mock variant entries' % (created_count, total)))
