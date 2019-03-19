import django_filters
from django import forms
from django.db import models
from django.contrib.postgres.fields import ArrayField, JSONField
from django.db.models import Count
from django.shortcuts import render

# Create your views here.
from django.contrib.auth.models import User, Group
from rest_framework import viewsets, permissions, filters
from django_filters import rest_framework as df_filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.views import APIView

from api.models import Source, Gene, Variant, Association, Phenotype, Evidence, EnvironmentalContext, VariantInSource
from api.serializers import (
    SourceSerializer, GeneSerializer,
    VariantSerializer, AssociationSerializer,
    PhenotypeSerializer, EvidenceSerializer, EnvironmentalContextSerializer, FullVariantSerializer,
    VariantInSourceSerializer
)


# svip data endpoints

class SourceViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Genes that we've discovered from harvesting.
    """
    queryset = Source.objects.all().order_by('name')
    serializer_class = SourceSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)


class GeneViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Genes that we've discovered from harvesting.
    """
    queryset = Gene.objects.all().order_by('symbol')
    serializer_class = GeneSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)


class VariantFilter(df_filters.FilterSet):
    gene = df_filters.ModelChoiceFilter(queryset=Gene.objects.all())
    gene_symbol = df_filters.CharFilter(field_name='gene__symbol', label='Gene Symbol')
    name = df_filters.CharFilter(field_name='name')
    description = df_filters.CharFilter(field_name='description')
    so_name = df_filters.AllValuesFilter(field_name='so_name', label='Sequence Ontology Name')
    sources = df_filters.BaseInFilter(field_name='sources', lookup_expr='contains')
    in_svip = df_filters.BooleanFilter(label='Is SVIP Variant?', method='filter_has_svipdata')

    # noinspection PyMethodMayBeStatic
    def filter_has_svipdata(self, queryset, name, value):
        if value:
            return queryset.filter(svipvariant__isnull=False)
        # otherwise, return all the variants, svip data or not
        return queryset


class VariantViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Genetic variants that are associated to particular genes.

    These can include modifications within genes as well as more generic
    "features", e.g. fusions between genes and gene amplifications.
    """
    # queryset = Variant.objects.all().order_by('name')
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)

    def get_queryset(self):
        if 'gene_pk' in self.kwargs:
            return Variant.objects.filter(gene_id=self.kwargs['gene_pk']).order_by('name')
        else:
            return Variant.objects.all().order_by('name')

    def get_serializer_class(self):
        if self.action == 'retrieve':
            return FullVariantSerializer
        return VariantSerializer

    filter_backends = (django_filters.rest_framework.DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter)
    filterset_class = VariantFilter
    # filter_fields = ('gene', 'name', 'description', 'so_name')
    search_fields = ('name', 'description', 'hgvs_c', 'hgvs_p', 'hgvs_g', 'so_name', 'gene__symbol')
    ordering_fields = ('name', 'hgvs_c', 'hgvs_p', 'hgvs_g', 'so_name')

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


class VariantInSourceViewSet(viewsets.ReadOnlyModelViewSet):
    """
    The entry for a specific variant in a specific source, e.g. EGFR L858R in CIViC.
    """
    serializer_class = VariantInSourceSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)

    def get_queryset(self):
        if 'variant_pk' in self.kwargs:
            q = VariantInSource.objects.filter(variant_id=self.kwargs['variant_pk'])
        else:
            q = VariantInSource.objects.all()
        return q.order_by('source__display_name')


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
    serializer_class = AssociationSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)

    def get_queryset(self):
        if 'variant_pk' in self.kwargs:
            q = Association.objects.filter(variant_id=self.kwargs['variant_pk'])
        elif 'variant_in_source_pk' in self.kwargs:
            q = Association.objects.filter(variant_in_source_id=self.kwargs['variant_in_source_pk'])
        else:
            q = Association.objects.all()

        return q.order_by('id')

    filter_backends = (django_filters.rest_framework.DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter,)
    filter_fields = (
        'variant_in_source__variant__gene', 'variant_in_source__source',
        'phenotype__term',
        'environmentalcontext__description',
        'drug_interaction_type'
    )
    ordering_fields = (
        'evidence_type',
        'evidence_direction',
        'clinical_significance',
        'evidence_level',
        'drug_labels',
    )

    search_fields = ('variant_in_source__variant__variant_name', 'variant_in_source__variant__description')


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
        in_svip = (request.GET.get('in_svip', False) == 'true')

        if search_term is not None and search_term != '':
            gq = Gene.objects.filter(symbol__icontains=search_term)
            vq = Variant.objects.filter(description__icontains=search_term)

            if in_svip:
                gq = gq.annotate(svip_vars=Count('variant__svipvariant')).filter(svip_vars__gt=0)
                vq = vq.filter(svipvariant__isnull=False)

            g_resp = list({'id': x.id, 'type': 'g', 'label': x.symbol} for x in gq)
            v_resp = list({'id': x.id, 'g_id': x.gene.id, 'type': 'v', 'label': x.description} for x in vq)

            resp = g_resp + v_resp
        else:
            # send back the full list of genes
            gq = Gene.objects.all()

            if in_svip:
                gq = gq.annotate(svip_vars=Count('variant__svipvariant')).filter(svip_vars__gt=0)

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
