from rest_framework import viewsets

from api.models import IcdOTopo, IcdOMorpho
from api.serializers.icdo import IcdOTopoSerializer, IcdOMorphoSerializer


class IcdOMorphoViewSet(viewsets.ReadOnlyModelViewSet):
    """
    A list of ICD-O morphological terms, referring to cancer types, e.g. "Adenocarcinoma".
    """

    # pagination_class = None  # disables pagination for this viewset
    serializer_class = IcdOMorphoSerializer
    queryset = IcdOMorpho.objects.all().order_by('id')

    def get_view_name(self):
        return "ICD-O Morphological Terms"

class IcdOTopoViewSet(viewsets.ReadOnlyModelViewSet):
    """
    A list of ICD-O topological terms, referring to locations in the body, e.g. "upper lip".
    """

    # pagination_class = None  # disables pagination for this viewset
    serializer_class = IcdOTopoSerializer
    queryset = IcdOTopo.objects.all().order_by('id')


    def get_view_name(self):
        return "ICD-O Topological Terms"
