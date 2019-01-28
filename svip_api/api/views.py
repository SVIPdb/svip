import django_filters
from django.shortcuts import render

# Create your views here.
from django.contrib.auth.models import User, Group
from rest_framework import viewsets, permissions, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.views import APIView

from api.models import Gene, Variant, Association, Phenotype, Evidence, EnvironmentalContext
from api.serializers import UserSerializer, GroupSerializer, GeneSerializer, \
    VariantSerializer, AssociationSerializer, \
    PhenotypeSerializer, EvidenceSerializer, EnvironmentalContextSerializer, FullVariantSerializer


# svip data endpoints

class GeneViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Genes that we've discovered from harvesting.
    """
    queryset = Gene.objects.all().order_by('symbol')
    serializer_class = GeneSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)


class VariantViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Genetic variants that are associated to particular genes.

    These can include modifications within genes as well as more generic
    "features", e.g. fusions between genes and gene amplifications.
    """
    queryset = Variant.objects.all().order_by('name')
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)

    def get_serializer_class(self):
        if self.action == 'retrieve':
            return FullVariantSerializer
        return VariantSerializer

    filter_backends = (django_filters.rest_framework.DjangoFilterBackend,filters.SearchFilter,)
    filter_fields = (
        'gene',
        'name',
        'description',
        'so_name'
    )
    search_fields = ('name', 'description', 'so_name', 'gene__symbol')

    @action(detail=False)
    def autocomplete(self, request):
        """
        Gets a list of variants for which the query term, 'q', occurs in its description.
        :param request:
        :return: a list of variant objects, consisting of just the id and description (called 'label') for brevity
        """
        resp = []
        search_term = request.GET.get('q', None)

        if search_term is not None:
            q = Variant.objects.filter(description__icontains=search_term)
            resp = list({'id': x.id, 'label': x.description} for x in q)

        return Response(resp)


class AssociationViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Association between a variant (and consequently a gene), and
    some kind of conclusion about that variant. The conclusion
    optionally consists of a phenotype, environmental context,
    and evidence suppporting the conclusion.

    Depending on the type of this association, the conclusion
    may be:
    <ul>
        <li><b>predictive:</b> in which case a drug may be suggested,
        <li><b>diagnostic:</b> if the variant is implicated in a disease,
        <li><b>prognostic:</b> i.e., a statement about outcome, or
        <li><b>predisposing:</b> (an indication that having this variant does or does not
    result in cancer).
    </ul>

    More information on these labels can be found
    on CIViC's website, <a href="https://civicdb.org/help/evidence/evidence-types">https://civicdb.org/help/evidence/evidence-types</a>.
    """
    queryset = Association.objects.all().order_by('id')
    serializer_class = AssociationSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)


class PhenotypeViewSet(viewsets.ReadOnlyModelViewSet):
    """
    A visible effect of the variant, e.g. a disease state.
    """
    queryset = Phenotype.objects.all().order_by('id')
    serializer_class = PhenotypeSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)


class EvidenceViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Supporting information for the conclusion forwarded by the
    association. This might include literature references, treatment
    advice,
    """
    queryset = Evidence.objects.all().order_by('id')
    serializer_class = EvidenceSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)


class EnvironmentalContextViewSet(viewsets.ReadOnlyModelViewSet):
    """
    API endpoint for viewing genes
    """
    queryset = EnvironmentalContext.objects.all().order_by('id')
    serializer_class = EnvironmentalContextSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)


# non-model-backed functional endpoints

class QueryView(viewsets.ViewSet):
    def list(self, request, format=None):
        """
        Gets a list of genes and variants for which the query term, 'q', occurs in its description.
        :param request:
        :return: a list of variant objects, consisting of just the id and description (called 'label') for brevity
        """
        resp = []
        search_term = request.GET.get('q', None)

        if search_term is not None and search_term != '':
            gq = Gene.objects.filter(symbol__icontains=search_term)
            g_resp = list({'id': x.id, 'type': 'g', 'label': x.symbol} for x in gq)
            vq = Variant.objects.filter(description__icontains=search_term)
            v_resp = list({'id': x.id, 'g_id': x.gene.id, 'type': 'v', 'label': x.description} for x in vq)

            resp = g_resp + v_resp
        else:
            # send back the full list of genes
            gq = Gene.objects.all()
            g_resp = list({'id': x.id, 'type': 'g', 'label': x.symbol} for x in gq)
            resp = g_resp

        return Response(resp)

    @action(detail=False)
    def stats(self, request):
        return Response({
            'genes': Gene.objects.count(),
            'variants': Variant.objects.count(),
            'phenotypes': Phenotype.objects.count()
        })
