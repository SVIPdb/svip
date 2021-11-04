from django.core.management.base import BaseCommand
from api.models.reference import Disease
from api.models.icdo import IcdOTopoApiDisease
from api.models.svip import DiseaseInSVIP

class Command(BaseCommand):
  help = 'Gets rid of duplidated diseases and attribute the associated data to the disease of reference'

  def handle(self, *args, **options):
    diseases = {}
    for disease in Disease.objects.all():

        print(disease.id)

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
                
                print(f"disease {disease.id} is a duplicate of disease {disease_to_keep}")

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
                    svip_disease.disease = disease_to_keep
                    print(disease_to_keep.id)
                    svip_disease.save()

                print('flag 1')
                for curation in disease.curationentry_set.all():
                    print(f'curation detected: ID is {curation.id}')
                    print(f"disease of curation should become {disease_to_keep.id}")
                    curation.disease = disease_to_keep
                    curation.save()
                print('flag 2')

                disease.delete()
                print('disease has been deleted.')

            else:
                diseases[disease.icd_o_morpho.id][topo_str] = disease.id
                print(f"disease {disease.id} is stored.")

    print(diseases)
