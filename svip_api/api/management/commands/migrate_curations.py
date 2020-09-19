import contextlib
import os
import sys

from django.core.management.base import BaseCommand
from django.core.serializers.json import DjangoJSONEncoder
from rest_framework.utils import json

from api.models import CurationEntry, Variant, Disease
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

    return {
        **({ k: v for k,v in entry.__dict__.items() if k != '_state' and 'id' not in k}), **{
            'disease': {
                'name': disease.name,
                'localization': disease.localization,
                'user_created': disease.user_created
            } if disease else None,
            'variant': {
                'hgvs_g': entry.variant.hgvs_g,
                'hgvs_c': entry.variant.hgvs_c,
                'description': entry.variant.description
            },
            'extra_variants': [
                {"gene__symbol": x.gene.symbol, "name": x.name}
                for x in entry.extra_variants.all()
            ]
        }
    }

def map_fields_to_entry(fields):
    variant = fields.pop('variant')
    disease = fields.pop('disease')
    extra_variants = fields.pop('extra_variants')

    try:
        extra_variants_list = [
            Variant.objects.get(**extra_variant)
            for extra_variant in extra_variants
        ]

    except Variant.DoesNotExist:
        raise Exception("A variant in extra_variants doesn't exist: %s" % str(extra_variants))

    try:
        return CurationEntry(
            variant=Variant.objects.get(**variant),
            disease=(
                Disease.objects.get_or_create(
                    name=disease['name'], localization=disease['localization'], defaults={ 'user_created': True }
                )
                if disease and disease.user_created else None
            ),
            extra_variants=extra_variants_list,
            **fields
        )

    except Variant.DoesNotExist:
        raise Exception("Couldn't find variant %s" % str(variant))

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

    def handle(self, *args, **options):
        if options['direction'] == 'import':
            self.import_entries(options)
        else:
            self.export_entries(options)

    def import_entries(self, options):
        with smart_open(options['target_file'], 'r') as fp:
            entries = json.load(fp)

            CurationEntry.objects.bulk_create([
                map_fields_to_entry(x)
                for x in entries
            ])

            self.stdout.write(self.style.SUCCESS('Read %d entries from source file' % len(entries)))


    def export_entries(self, options):
        # check if the target file exists, and prompt to overwrite if so
        if os.path.exists(options['target_file']) and not boolean_input("Target file exists; do you want to overwrite it?"):
            return

        with smart_open(options['target_file'], 'w') as fp:
            entries = [
                map_entry_to_fields(x)
                for x in CurationEntry.objects.all().select_related('variant', 'disease')
            ]
            fp.write(json.dumps(entries, cls=DjangoJSONEncoder))

            if options['target_file'] != '-':
                self.stdout.write(self.style.SUCCESS('Wrote %d entries to destination file' % len(entries)))
