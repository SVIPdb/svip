from itertools import chain

from django.core.management.base import BaseCommand
from django.db import transaction

from api.models import CurationEntry, DiseaseInSVIP, VariantInSVIP


class Command(BaseCommand):
    help = 'Constructs DiseaseInSVIP instances for any CurationEntry items in the db'

    def add_arguments(self, parser):
        parser.add_argument('--prune-orphans', action='store_true', default=False)

    def handle(self, *args, **options):
        with transaction.atomic():
            curation_entries = CurationEntry.objects.all()
            created_count = 0

            for entry in curation_entries:
                results = entry.ensure_svip_provenance()

                for result in results:
                    variant = result['variant']
                    svip_variant, svip_created = result['svip']
                    disease_in_svip, created = result['diseaseinsvip']

                    if svip_created:
                        if options['verbosity'] >= 2:
                            self.stdout.write("Created VariantInSVIP %s" % str(variant))

                    if created:
                        created_count += 1
                        if options['verbosity'] >= 2:
                            self.stdout.write("Created DiseaseInSVIP %s (%s)" % (str(variant), entry.disease))

            # prune excess models
            if options['prune_orphans']:
                pruned, details = DiseaseInSVIP.objects.prune_orphans()
                self.stdout.write(
                    self.style.SUCCESS(
                        "Pruned %d DiseaseInSVIP entries (%s)" % (pruned, details)
                    )
                )

            self.stdout.write(
                self.style.SUCCESS(
                    "Created %d DiseaseInSVIP entries from %d curation entries" % (created_count, curation_entries.count())
                )
            )
