from django.core.management.base import BaseCommand
from api.models.reference import Disease
from api.models.icdo import IcdOTopoApiDisease
from api.models.svip import DiseaseInSVIP


def clean_diseases_in_svip():
    for svip_disease in DiseaseInSVIP.objects.all():
        current_queryset = DiseaseInSVIP.objects.filter(svip_variant=svip_disease.svip_variant, disease=svip_disease.disease)
        if len(current_queryset) > 1:
            svip_disease_to_keep = current_queryset.first()
            for duplicate in current_queryset.all():
                if duplicate != svip_disease_to_keep:
                    for sample in duplicate.sample_set.all():
                        sample.disease_in_svip = svip_disease_to_keep
                        sample.save()
                    print(f"svip_disease {duplicate.id} about to be deleted")
                    duplicate.delete()


def clean_diseases():
    diseases = {}
    for disease in Disease.objects.all():

        if len(disease.icdotopoapidisease_set.all()) > 0:
            topo_list = []
            for topo_id in disease.icdotopoapidisease_set.values_list('icd_o_topo__id', flat=True):
                topo_list.append(topo_id)
            topo_list.sort()

            # sort topo IDs and place them in a string so the key has the IDs always in the same order (diseases must have the same key to be identified as duplicates)
            topo_str = ''
            for topo_id in topo_list:
                topo_str += str(f"{topo_id}, ")

            # check if morpho is already stored
            if not disease.icd_o_morpho.id in diseases:
                diseases[disease.icd_o_morpho.id] = {}

            # if there is already a disease ID for this set of topo IDs: pass the information of current disease to that other disease, and delete current disease
            if topo_str in diseases[disease.icd_o_morpho.id]:
                disease_to_keep = Disease.objects.get(id=diseases[disease.icd_o_morpho.id][topo_str])
                print(f"\ndisease {disease.id} is a duplicate of disease {disease_to_keep}")

                for association in disease.curation_associations.all():
                    association.disease = disease_to_keep
                    association.save()

                for req in disease.curationrequest_set.all():
                    req.disease = disease_to_keep
                    req.save()

                for submitted_var in disease.submittedvariant_set.all():
                    submitted_var.curation_disease = disease_to_keep
                    submitted_var.save()

                for svip_disease in disease.diseaseinsvip_set.all():
                    
                    # make sure the edited disease in svip won't have the same params as an arealdy exsiting one
                    current_queryset = DiseaseInSVIP.objects.filter(svip_variant=svip_disease.svip_variant, disease=disease_to_keep)
                    if len(current_queryset) > 0:
                        svip_disease_to_keep = current_queryset.first()
                        for sample in svip_disease.sample_set.all():
                            sample.disease_in_svip = svip_disease_to_keep
                            sample.save()
                        print(f"svip_disease {svip_disease.id} about to be deleted")
                        svip_disease.delete()
                    else:
                        svip_disease.disease = disease_to_keep
                        svip_disease.save()

                for curation in disease.curationentry_set.all():
                    curation.disease = disease_to_keep
                    curation.save()

                disease.delete()
                print('disease has been deleted.\n')

            else:
                diseases[disease.icd_o_morpho.id][topo_str] = disease.id
                print(f"disease {disease.id} is stored.")


class Command(BaseCommand):
    help = 'Gets rid of duplidated diseases and attribute the associated data to the disease of reference'

    def handle(self, *args, **options):
        clean_diseases_in_svip()
        clean_diseases()
