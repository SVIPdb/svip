from django.core.management.base import BaseCommand
from django.db import transaction

from api.models import Variant


class Command(BaseCommand):
    help = \
        'Makes all references to the removed variant point to the kept variant. Deletes the removed variant afterward.' \
        'Use this command to clean up spurious variants created when importing curation entries.'

    def add_arguments(self, parser):
        parser.add_argument('kept-id', type=int, help='Variant to keep')
        parser.add_argument('removed-id', type=int, help='Variant to remove')

    def handle(self, *args, **options):
        # make everything that referenced 'removed' now reference 'kept'
        with transaction.atomic():
            # look up source and dest variants
            kept_variant = Variant.objects.get(id=options['kept-id'])
            removed_variant = Variant.objects.get(id=options['removed-id'])

            # swap references to 'removed_variant' for the new 'kept variant'
            removed_variant.variantinsource_set.update(variant=kept_variant)
            removed_variant.variantcuration_set.update(variant=kept_variant)

            # since this is a nullable 1-to-1 relation, we need to check if it exists in a special way
            if hasattr(removed_variant, 'variantinsvip') and removed_variant.variantinsvip:
                removed_variant.variantinsvip.variant = kept_variant
                removed_variant.variantinsvip.save()

            removed_variant.curationentry_set.update(variant=kept_variant)
            removed_variant.variantcomment_set.update(variant=kept_variant)
            removed_variant.curationrequest_set.update(variant=kept_variant)

            removed_variant.save()
            removed_variant.delete()

        print(self.style.SUCCESS("Replaced variant %d with %d" % (options['removed-id'], options['kept-id'])))
