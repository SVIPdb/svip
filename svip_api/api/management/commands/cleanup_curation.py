from django.core.management.base import BaseCommand
from django.db import transaction
from django.db.models import Q, Count

from api.models import CurationEntry, Variant, Disease
from api.models.svip import VariantCuration


class Command(BaseCommand):
    help = 'Cleans up curation entries from svip-test'

    def add_arguments(self, parser):
        pass

    def handle(self, *args, **options):
        with transaction.atomic():

            # ---------------------------------------------------------------------------------
            # --- if the comment is "REMOVE DISEASE: <>", update the mendelian disease in certain cases...
            # ---------------------------------------------------------------------------------

            complex_removes = CurationEntry.objects.filter(comment__startswith='REMOVE DISEASE AND REPLACE BY:')

            for entry in complex_removes:
                if 'Li-Fraumeni syndrome' in entry.comment:
                    entry.associated_mendelian_diseases = 'Li-Fraumeni syndrome'
                    entry.disease = None
                elif 'Mucinous adenocarcinoma' in entry.comment:
                    new_disease, created = Disease.objects.get_or_create(name='Mucinous Adenocarcinoma', defaults={'user_created': True})
                    entry.disease = new_disease
                else:
                    # parse the disease name out of the comment
                    name = entry.comment.split(":")[1].strip().title()
                    new_disease, created = Disease.objects.get_or_create(name=name, defaults={'user_created': True})
                    entry.disease = new_disease
                entry.comment = None
                entry.save()

            self.stdout.write(self.style.SUCCESS("Updates 'diseases' in entries where 'comment' matched 'REMOVE DISEASE: ': %d" % len(complex_removes)))

            # ---------------------------------------------------------------------------------
            # --- if the comment is "REMOVE DISEASE", set the disease to None
            # --- also clears any remaining entries w/"Acral lentiginous malignant melanoma of skin"
            # ---------------------------------------------------------------------------------

            affected = (
                CurationEntry.objects
                    .filter(
                        Q(comment='REMOVE DISEASE') |
                        Q(disease__name="Acral lentiginous malignant melanoma of skin")
                    )
                    .update(disease=None, comment=None)
            )
            self.stdout.write(self.style.SUCCESS("Cleared 'disease' field where entry matched 'REMOVE DISEASE' or disease matched 'Acral...': %d" % affected))


            # ---------------------------------------------------------------------------------
            # --- where comment mentions 'Double', add the variant that isn't the primary variant as the secondary variant
            # ---------------------------------------------------------------------------------

            double_entries = (
                CurationEntry.objects
                    .filter(comment__contains='Double mutant').select_related('variant')
            )

            for entry in double_entries:
                # parses a comment like "Double mutant: CTNNB1 T41A and BRAF V600E." into ['CTNNB1 T41A', 'BRAF V600E']
                var_a, var_b = [x.replace('.', '') for x in entry.comment.split(": ")[1].split(" and ")]

                # identifies which is the non-primary variant
                secondary_var = var_a if entry.variant.description == var_b else var_b

                # creates an association that'll populate extra_variants in CurationEntry
                # we choose the variant with the most sources associated with it
                target_variant = (
                    Variant.objects
                    .filter(description=secondary_var)
                    .annotate(
                        num_sources=Count('variantinsource')
                    )
                    .order_by('-num_sources').first()
                )

                VariantCuration.objects.create(
                    curationentry=entry,
                    variant=target_variant
                )
                entry.comment = None
                entry.save()

            self.stdout.write(self.style.SUCCESS("Updated entries containing 'Double Mutant': %d" % len(double_entries)))
