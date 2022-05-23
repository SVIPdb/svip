from django.shortcuts import render
import django_filters
from django.db.models import Prefetch, Q
from django.http import HttpResponse, JsonResponse
from django_filters import rest_framework as df_filters
from django_filters.filterset import FilterSet
# Create your views here.
from rest_framework import filters, permissions, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from api.models import (Association, CollapsedAssociation, DiseaseInSVIP,
                        EnvironmentalContext, Evidence, Gene, Phenotype,
                        Source, Variant, VariantInSource)
from api.serializers import (AssociationSerializer,
                             CollapsedAssociationSerializer,
                             EnvironmentalContextSerializer,
                             EvidenceSerializer, FullVariantSerializer,
                             GeneSerializer, PhenotypeSerializer,
                             SimpleVariantSerializer, SourceSerializer,
                             VariantInSourceSerializer, VariantSerializer)
# svip data endpoints
from api.serializers.genomic_svip import OnlySVIPVariantSerializer
from api.shared import clinical_significance, pathogenic
import re
from api.utils import render_to_pdf


def change_from_hgvs(x):
    if not x or not ":" in x:
        return x
    return x.split(":")[1]


def var_to_position(variant):
    r = r'.*:g\.([0-9]+)(.*)$'
    if (not variant.hgvs_g or not variant.chromosome or not re.match(r, variant.hgvs_g)):
        return None
    return "chr" + variant.chromosome + ":" + re.sub(r'.*(:g\.)(?![0-9]+)?', '', variant.hgvs_g, 2)


def VariantSummaryView(request, pk: int):
    from api.models import CurationEntry
    variant = Variant.objects.get(id=pk)
    # authed_set = CurationEntry.objects.filter(owner=request.user)
    authed_set = CurationEntry.objects.all()
    if request.GET.get('owner') == 'own':
        authed_set = CurationEntry.objects.filter(owner=request.user)
    curation_entries = authed_set.filter(
        Q(extra_variants=variant) | Q(variant=variant))
    allele_frequency = 'unavailable'
    if variant.mv_info:
        if variant.mv_info['gnomad_genome']:
            allele_frequency = "gnomAD: " + str(
                round(variant.mv_info['gnomad_genome']['af']['af'] * 100.0, 4)) + '%'
        elif variant.mv_info['exac']:
            allele_frequency = "ExAC: " + str(
                round(variant.mv_info['exac']['af'] * 100.0, 4))
    context = {'pk': pk,
               'variant': variant,
               'curation_entries': curation_entries,
               'allele_frequency': allele_frequency,
               'hgvs_c': change_from_hgvs(variant.hgvs_c),
               'hgvs_p': change_from_hgvs(variant.hgvs_p),
               'hgvs_g': change_from_hgvs(variant.hgvs_g),
               'position': var_to_position(variant),
               'scores': [1, 2, 3],
               "user": request.user}
    html = render(request, 'variant_summary.html', context)
    pdf = render_to_pdf('variant_summary_pdf.html', context)
    # return render(request, 'variant_summary.html', context)
    if request.GET.get('if_pdf'):
        return pdf
    else:
        return html


class SourceViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Public sources harvested by g2p-aggregator
    """
    queryset = Source.objects.all().order_by('name')
    serializer_class = SourceSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)


class GeneFilter(df_filters.FilterSet):
    aliases = df_filters.BaseInFilter(lookup_expr='contains')
    prev_symbols = df_filters.BaseInFilter(lookup_expr='contains')

    class Meta:
        model = Gene
        fields = ('symbol', 'aliases', 'prev_symbols')


class GeneViewSet(viewsets.ModelViewSet):
    """
    Genes that we've discovered from harvesting.
    """
    queryset = Gene.objects.all().order_by('symbol')
    serializer_class = GeneSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)

    filter_backends = (django_filters.rest_framework.DjangoFilterBackend,
                       filters.SearchFilter, filters.OrderingFilter,)
    filterset_class = GeneFilter
    search_fields = ['symbol', 'aliases', 'prev_symbols']


class VariantFilter(df_filters.FilterSet):
    gene = df_filters.ModelChoiceFilter(queryset=Gene.objects.all())
    gene_symbol = df_filters.CharFilter(
        field_name='gene__symbol', label='Gene Symbol')
    name = df_filters.CharFilter(field_name='name')
    description = df_filters.CharFilter(field_name='description')
    so_name = df_filters.AllValuesFilter(
        field_name='so_name', label='Sequence Ontology Name')
    sources = df_filters.BaseInFilter(
        field_name='sources', lookup_expr='contains')
    in_svip = df_filters.BooleanFilter(
        label='Is SVIP Variant?', method='filter_has_svipdata')

    # noinspection PyMethodMayBeStatic
    def filter_has_svipdata(self, queryset, name, value):
        if value:
            # we require the .distinct() here because we occasionally have multiple VariantInSVIP entries
            # keyed to the same variant (although that's clearly not great), and this implicit join
            # causes those variants to be repeated as many times as there are referring VinSVIP entries
            return queryset.filter(variantinsvip__isnull=False).distinct()
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
            q = Variant.objects.filter(gene_id=self.kwargs['gene_pk'])
        else:
            q = Variant.objects.all()

        # attempting to reduce the number of queries
        q = q.select_related('gene')

        # if they want inline svip data, be sure to prefetch it and all its dependencies
        if self.request.GET.get('inline_svip_data') == 'true' or self.action == 'retrieve':
            q = (q
                 .select_related('variantinsvip')
                 .prefetch_related(
                     Prefetch(
                         'variantinsvip__diseaseinsvip_set', queryset=(
                             DiseaseInSVIP.objects
                             .select_related('disease', 'svip_variant', 'svip_variant__variant')
                             .prefetch_related(
                                 'sample_set',
                                 'disease__curationentry_set',
                                 'disease__curationentry_set__owner'
                             )
                         )
                     ),
                     Prefetch(
                         'variantinsource_set', queryset=VariantInSource.objects.filter(source__no_associations=False)
                     )
                 )
                 )

        return q.order_by('name')

    def get_serializer_class(self):
        if self.request.GET.get('simple') == 'true':
            return SimpleVariantSerializer
        elif self.action == 'retrieve':
            return FullVariantSerializer
        elif self.request.GET.get('inline_svip_data') == 'true':
            return OnlySVIPVariantSerializer
        return VariantSerializer

    filter_backends = (django_filters.rest_framework.DjangoFilterBackend,
                       filters.SearchFilter, filters.OrderingFilter)
    filterset_class = VariantFilter
    # filter_fields = ('gene', 'name', 'description', 'so_name')
    search_fields = (
        'name', 'description', 'hgvs_c', 'hgvs_p', 'hgvs_g', 'so_name', 'gene__symbol', 'sources'
    )
    ordering_fields = ('name', 'hgvs_c', 'hgvs_p',
                       'hgvs_g', 'so_name', 'sources')

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

    @action(detail=True)
    def curation_summary(self, request, pk):
        """
        Produces a summary of curation data for the given variant, either for a specific disease
        if 'disease_id' is specified as a parameter, or groups by all diseases associated by a
        curation entry with this variant.

        :param request:
        :param pk: the primary key of the variant
        :return:
        """
        from api.models import Disease
        from api.serializers.reference import DiseaseSerializer
        from api.models import CurationEntry

        variant = Variant.objects.get(id=pk)
        disease_id = request.GET.get('disease_id', None)

        # first, get curation entries that we should be able to view based on our access privileges
        # returns curation entries in which either the main variant or one of the extra variants is this variant
        authed_set = CurationEntry.objects.authed_curation_set(request.user)
        curation_entries = authed_set.filter(
            Q(extra_variants=variant) | Q(variant=variant))

        def summarize_disease(ce_entries, target_disease):
            disease_ce_entries = ce_entries.filter(disease=target_disease)

            return {
                'disease': DiseaseSerializer(target_disease).data,
                'pathogenic': pathogenic(disease_ce_entries),
                'clinical_significance': clinical_significance(disease_ce_entries)
            }

        if disease_id:
            response = summarize_disease(
                curation_entries, Disease.objects.get(id=disease_id))
        else:
            response = dict(
                (disease.name, summarize_disease(curation_entries, disease))
                for disease in Disease.objects.filter(curationentry__id__in=[x.id for x in curation_entries])
            )

        return JsonResponse(response)


class VariantInSourceViewSet(viewsets.ReadOnlyModelViewSet):
    """
    The entry for a specific variant in a specific source, e.g. EGFR L858R in CIViC.
    """
    serializer_class = VariantInSourceSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)

    def get_queryset(self):
        if 'variant_pk' in self.kwargs:
            q = VariantInSource.objects.filter(
                variant_id=self.kwargs['variant_pk'])
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
            q = Association.objects.filter(
                variant_id=self.kwargs['variant_pk'])
        elif 'variant_in_source_pk' in self.kwargs:
            q = Association.objects.filter(
                variant_in_source_id=self.kwargs['variant_in_source_pk'])
        else:
            q = Association.objects.all()

        return q.order_by('id')

    filter_backends = (django_filters.rest_framework.DjangoFilterBackend,
                       filters.SearchFilter, filters.OrderingFilter,)
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
        'phenotype__term',
        'environmentalcontext__description',
        'extras__num_submissions'
    )

    search_fields = (
        'variant_in_source__variant__name',
        'variant_in_source__variant__description',
        'evidence_type',
        'evidence_direction',
        'clinical_significance',
        'evidence_level',
        'drug_labels',
        'phenotype__term',
        'environmentalcontext__description',
        'evidence__publications'
    )


class CollapsedAssociationViewSet(viewsets.ReadOnlyModelViewSet):
    """
    A simplified version of Association that collapses entries that have the same information except the source
    evidence ID and the list of publications, to circumvent denormalized entries in public databases.

    Refer to Association for more details.
    """
    serializer_class = CollapsedAssociationSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)

    def get_queryset(self):
        if 'variant_in_source_pk' in self.kwargs:
            q = CollapsedAssociation.objects.filter(
                variant_in_source_id=self.kwargs['variant_in_source_pk'])
        else:
            q = CollapsedAssociation.objects.all()

        return q.order_by('id')

    filter_backends = (django_filters.rest_framework.DjangoFilterBackend,
                       filters.SearchFilter, filters.OrderingFilter,)
    filter_fields = (
        'variant_in_source__variant__gene', 'variant_in_source__source',
        'disease',
        'contexts'
    )
    ordering_fields = (
        'evidence_type',
        'evidence_direction',
        'clinical_significance',
        'evidence_levels',
        'drug_labels',
        'disease',
        'contexts'
    )

    search_fields = (
        'variant_in_source__variant__name',
        'variant_in_source__variant__description',
        'evidence_type',
        'evidence_direction',
        'clinical_significance',
        'evidence_levels',
        'drug_labels',
        'disease',
        'contexts',
        'publications'
    )


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
