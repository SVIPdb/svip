from rest_framework import viewsets

from api.models import Drug, Disease
from api.serializers.reference import DrugSerializer, DiseaseSerializer


class DrugViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Lists drugs as defined by the INN.

    More information here: [Lists of Recommended and Proposed INNs](https://www.who.int/medicines/publications/druginformation/innlists/en/)
    """
    pagination_class = None  # disables pagination for this viewset
    serializer_class = DrugSerializer
    queryset = Drug.objects.all().order_by('medicine_name')


class DiseaseViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Lists diseases related to oncology as defined by WHO ICDO-3.

    More information here: [International Classification of Diseases for Oncology](https://www.who.int/classifications/icd/adaptations/oncology/en/)
    """
    # pagination_class = None  # disables pagination for this viewset
    serializer_class = DiseaseSerializer
    queryset = Disease.objects.all().order_by('icd_o_morpho__term')
