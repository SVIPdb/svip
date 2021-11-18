from django.core.management.base import BaseCommand
from api.models.reference import Disease
from api.models.icdo import IcdOTopoApiDisease
from api.models.svip import DiseaseInSVIP


def change_variant_names():
    for variant in Variant.objects.all():
        #if not variant.hgvs_p == None:
        #    variant.name =
        variant.save()


class Command(BaseCommand):
    help = 'Harmonize all the names of the variant using their HGVSp expression'

    def handle(self, *args, **options):
        change_variant_names()
