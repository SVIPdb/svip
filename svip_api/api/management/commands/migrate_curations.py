import contextlib
import os
import sys

from django.contrib.auth.models import User
from django.core.management.base import BaseCommand
from django.core.serializers.json import DjangoJSONEncoder
from django.db import transaction
from rest_framework.utils import json

from api.models import CurationEntry, Variant, Disease, Gene
from api.support.management import boolean_input


@contextlib.contextmanager
def smart_open(filename, mode):
    if filename != '-':
        fh = open(filename, mode)
    else:
        fh = sys.stdin if mode.startswith('r') else sys.stdout

    try:
        yield fh
    finally:
        if fh is not sys.stdout and fh is not sys.stdin:
            fh.close()

def map_entry_to_fields(entry):
    disease = getattr(entry, 'disease')

    blacklisted_fields = [
        '_state', 'id', 'disease_id', 'variant_id', 'owner_id'
    ]

    return {
        **({ k: v for k,v in entry.__dict__.items() if k not in blacklisted_fields}), **{
            'disease': {
                'name': disease.name,
                'localization': disease.localization,
                'user_created': disease.user_created
            } if disease else None,
            'owner': {
                'username': entry.owner.username,
                'first_name': entry.owner.first_name,
                'last_name': entry.owner.last_name,
                'email': entry.owner.email
            },
            'variant': {
                "gene__symbol": entry.variant.gene.symbol,
                "name": entry.variant.name,
                "hgvs_c": entry.variant.hgvs_c,
                "hgvs_p": entry.variant.hgvs_p,
                "reference_name": entry.variant.reference_name,
                "chromosome": entry.variant.chromosome,
                "start_pos": entry.variant.start_pos,
                "dbsnp_ids": entry.variant.dbsnp_ids
            },
            'extra_variants': [
                {"gene__symbol": x.gene.symbol, "name": x.name}
                for x in entry.extra_variants.all()
            ]
        }
    }

def create_entry_from_fields(fields):
    variant = fields.pop('variant')
    disease = fields.pop('disease')
    owner = fields.pop('owner')
    extra_variants = fields.pop('extra_variants')

    gene_symbol = variant.pop('gene__symbol')
    variant, created_variant = Variant.objects.get_or_create(
        gene=Gene.objects.get_or_create(symbol=gene_symbol)[0],
        name=variant['name'],
        hgvs_c=variant['hgvs_c'],
        defaults={**variant, **{'description': "%s %s" % (gene_symbol, variant['name'])}}
    )

    if created_variant:
        print("Created variant %s" % variant.description)

    try:
        extra_variants_list = [
            Variant.objects.get(**extra_variant)
            for extra_variant in extra_variants
        ]
    except Variant.DoesNotExist:
        raise Exception("A variant in extra_variants doesn't exist: %s" % str(extra_variants))

    owner, created_owner = User.objects.get_or_create(username=owner['username'], defaults=owner)
    if created_owner:
        print("Created user %s (%d)" % (owner.username, owner.id))

    new_entry = CurationEntry(
        variant=variant,
        owner=owner,
        disease=(
            Disease.objects.get_or_create(
                name=disease['name'], localization=disease['localization'], defaults={ 'user_created': True }
            )[0]
            if disease and disease['user_created'] else None
        ),
        **fields
    )
    new_entry.save()

    new_entry.extra_variants.set(extra_variants_list)
    new_entry.save()

    return new_entry


class Command(BaseCommand):
    help = 'Migrates curation entries between SVIP installations'

    def add_arguments(self, parser):
        parser.add_argument(
            'direction',
            help='Whether to import or export data', choices=['import', 'export']
        )
        parser.add_argument(
            '--target-file',
            help='JSON-formatted curation entries', default='-'
        )
        parser.add_argument(
            '--create-users',
            action='store_true',
            help="If specified, creates non-existent users referenced by curation entries",
        )
        parser.add_argument(
            '--genes', type=str,
            help='comma-delimited list of genes to export', default=None
        )

    def handle(self, *args, **options):
        if options['direction'] == 'import':
            self.import_entries(options)
        else:
            self.export_entries(options)

    def import_entries(self, options):
        with transaction.atomic():
            with smart_open(options['target_file'], 'r') as fp:
                entries = json.load(fp)

                gene_list = options['genes'].split(",") if options['genes'] else None

                for entry in entries:
                    # skip entries not mentioned in the gene list
                    if gene_list and entry['variant']['gene__symbol'] not in gene_list:
                        continue

                    create_entry_from_fields(entry)

                self.stdout.write(self.style.SUCCESS('Read %d entries from source file' % len(entries)))


    def export_entries(self, options):
        # check if the target file exists, and prompt to overwrite if so
        if os.path.exists(options['target_file']) and not boolean_input("Target file exists; do you want to overwrite it?"):
            return

        with transaction.atomic():
            with smart_open(options['target_file'], 'w') as fp:
                qset = CurationEntry.objects.select_related('variant', 'variant__gene', 'disease')

                if options['genes']:
                    qset = (qset.objects
                        .filter(variant__gene__symbol__in=options['genes'].split(","))
                    )

                entries = [
                    map_entry_to_fields(x)
                    for x in qset
                ]
                fp.write(json.dumps(entries, cls=DjangoJSONEncoder))

                if options['target_file'] != '-':
                    self.stdout.write(self.style.SUCCESS('Wrote %d entries to destination file' % len(entries)))
