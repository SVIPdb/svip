# Command to fix the sources based on in what variant sources there are evidences for
# from public sources we adjust the sources array in the variant itself

from django.core.management.base import BaseCommand
from models.genomic import Variant
from tqdm import tqdm
from time import sleep


class Command(BaseCommand):

    help = 'Adjusts the source array in a variant based on what evidences are available from public sources (variantinsource)'

    def add_arguments(self, parser):
        return super().add_arguments(parser)

    def handle(self, *args, **options):
        with tqdm(total=Variant.objects.count()) as pbar:
            for variant in Variant.objects.all():
                sources = []
                variant_in_source = variant.variantinsource_set.all()
                for vis in variant_in_source:
                    sources.append(vis.source.name)

                variant.sources = sources
                variant.save()
                sleep(0.01)
                pbar.set_description("Processing %s" % str(variant))
                pbar.update(1)
