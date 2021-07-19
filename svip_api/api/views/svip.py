import hgvs.assemblymapper
import hgvs.dataproviders.uta
import hgvs.normalizer
import django_filters
import hgvs.parser
from django.contrib.postgres.aggregates import ArrayAgg
from django.db.models import Prefetch, Q
from django.http import JsonResponse
from hgvs.exceptions import HGVSParseError
from rest_framework import viewsets, permissions, filters, status
from rest_framework.decorators import action
from rest_framework.exceptions import PermissionDenied

from api.models.svip import SummaryComment, CurationReview
from api.models import (
    VariantInSVIP, Sample,
    DiseaseInSVIP,
    CurationEntry,
    Disease,
)
from api.models.svip import SubmittedVariant, SubmittedVariantBatch, CurationRequest
from api.permissions import IsCurationPermitted, IsSampleViewer, IsSubmitter
from api.serializers import (
    VariantInSVIPSerializer, SampleSerializer
)
from api.serializers.svip import (
    CurationEntrySerializer, DiseaseInSVIPSerializer, SubmittedVariantBatchSerializer,
    SubmittedVariantSerializer, CurationRequestSerializer, SummaryCommentSerializer, CurationReviewSerializer
)
from api.support.history import make_history_response
from api.utils import json_build_fields


# ================================================================================================================
# === Variant Aggregation
# ================================================================================================================
from svip_server.utils import DisabledHTMLFilterBackend


class VariantInSVIPViewSet(viewsets.ModelViewSet):
    """
    Connects a variant, e.g. EGFR L858R, to its SVIP-specific data. Currently that consists of samples
    and curation data, but more will come in the future.
    """
    serializer_class = VariantInSVIPSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)

    def get_serializer_context(self):
        return {'request': self.request}

    def get_queryset(self):
        print(self.kwargs)
        if 'variant_pk' in self.kwargs:
            q = VariantInSVIP.objects.filter(
                variant_id=self.kwargs['variant_pk'])
        else:
            q = VariantInSVIP.objects.all()

        q = (q
             .select_related('variant')
             .prefetch_related(
                 Prefetch('diseaseinsvip_set', queryset=(
                     DiseaseInSVIP.objects
                     .select_related('disease', 'svip_variant', 'svip_variant__variant')
                     .prefetch_related(
                         'sample_set'
                     )
                 )
                 ),
                 # Prefetch('diseaseinsvip_set', queryset=DiseaseInSVIP.objects.prefetch_related('sample_set')),
                 # 'diseaseinsvip_set', 'diseaseinsvip_set__sample_set'
             )
             )

        return q

    filter_backends = (
        django_filters.rest_framework.DjangoFilterBackend, filters.SearchFilter,)
    filter_fields = (
        'variant__gene',
        'variant__gene__symbol',
        'variant__name'
    )

    search_fields = (
        'variant__gene__symbol',
        'variant__name',
        'disease__icd_o_morpho__term',
        'summary_comments'
    )

    @action(detail=True)
    def history(self, request, pk):
        print("action is executed")
        entry = VariantInSVIP.objects.get(id=pk)
        return make_history_response(entry, add_created_by=False)


# ================================================================================================================
# === Disease Aggregation
# ================================================================================================================

class DiseaseInSVIPViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Connects a variant, e.g. EGFR L858R, to its SVIP-specific data. Currently that consists of samples
    and curation data, but more will come in the future.
    """
    serializer_class = DiseaseInSVIPSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)

    def get_serializer_context(self):
        return {'request': self.request}

    def get_queryset(self):
        if 'svip_variant_pk' in self.kwargs:
            q = DiseaseInSVIP.objects.filter(
                svip_variant_id=self.kwargs['svip_variant_pk'])
        else:
            q = DiseaseInSVIP.objects.all()

        # add in joined fields
        q = q.prefetch_related('sample_set')

        return q


# ================================================================================================================
# === Curation
# ================================================================================================================

class CurationRequestViewSet(viewsets.ModelViewSet):
    serializer_class = CurationRequestSerializer
    queryset = (
        CurationRequest.objects
        .prefetch_related('variant', 'variant__gene', 'submission')
        .order_by('-created_on')
    )


class CurationEntryFilter(django_filters.FilterSet):
    from api.models.svip import CURATION_STATUS

    status_ne = django_filters.ChoiceFilter(
        field_name='status', choices=tuple(CURATION_STATUS.items()),
        lookup_expr='iexact', exclude=True
    )
    variant_ref = django_filters.NumberFilter(method='any_variant_ref')

    @staticmethod
    def any_variant_ref(queryset, name, value):
        return queryset.filter(Q(variant_id=value) | Q(extra_variants=value))

    class Meta:
        model = CurationEntry
        fields = (
            'owner',
            'disease',
            'variant',
            'variant__name',
            'variant__gene__symbol',
            'extra_variants',
            'status',
            'status_ne'
        )


def lookup_disease_for_id(x):
    if not x:
        return "(none)"

    try:
        return Disease.objects.get(id=x).name
    except Disease.DoesNotExist:
        return "(unknown: %s)" % str(x)


def remap_curation_history_fields(field, value):
    """
    Produces customizable readable identifiers in the history for values that are stored as IDs.

    :param field: the field to remap
    :param value: the value (e.g., an ID)
    :return: if a remap for the field exists the readable value, else the original value
    """
    CURATION_DELTA_MAPS = {
        'disease': lookup_disease_for_id
    }

    return CURATION_DELTA_MAPS[field](value) if field in CURATION_DELTA_MAPS else value


class CurationEntryViewSet(viewsets.ModelViewSet):
    """
    Curation entry for a specific variant w/SVIP data and disease.
    """
    serializer_class = CurationEntrySerializer
    permission_classes = (
        permissions.IsAuthenticatedOrReadOnly, IsCurationPermitted)

    filter_backends = (DisabledHTMLFilterBackend,
                       filters.SearchFilter, filters.OrderingFilter,)
    filterset_class = CurationEntryFilter
    ordering_fields = (
        "action",
        "created_on",
        "disease__icd_o_morpho__term",
        "drugs",
        "effect",
        "last_modified",
        "owner_name",
        "references",
        "status",
        "tier_level",
        "tier_level_criteria",
        "type_of_evidence",
        "variant__gene__symbol",
        "variant__name",
    )
    search_fields = (
        'annotations',
        'variant__description',
        'disease__icd_o_morpho__term',
        'comment',
        'drugs',
        'interactions',
        'effect',
        'mutation_origin',
        'references',
        'status',
        'summary',
        'support',
        'tier_level',
        'tier_level_criteria',
        'type_of_evidence',
    )

    def get_serializer_context(self):
        return {'request': self.request}

    @staticmethod
    def _nice_username(obj):
        if not obj:
            return "N/A"
        fullname = ("%s %s" % (obj.first_name, obj.last_name)).strip()
        return fullname if fullname else obj.username

    @action(detail=False, methods=['POST'])
    def bulk_submit(self, request):
        # for every ID in items, if it's saved upgrade it to a draft
        entryIDs = [int(x) for x in request.GET['items'].split(",")]
        result = CurationEntry.objects.filter(
            id__in=entryIDs, status='saved').update(status='submitted')
        return JsonResponse({
            "input": entryIDs,
            "changed": result
        })

    @action(detail=True)
    def history(self, request, pk):
        entry = CurationEntry.objects.get(id=pk)
        return make_history_response(entry, remap_curation_history_fields)

    @action(detail=False)
    def all_references(self, request):
        return JsonResponse({
            'references': {
                x['references']: x['recs'] for x in (
                    CurationEntry.objects
                    .select_related('variant', 'variant__gene')
                    .values('references')
                    .annotate(recs=ArrayAgg(json_build_fields(
                        id='id', variant_id='variant__id', gene_id='variant__gene__id', etype='type_of_evidence'
                    )))
                )
            }
        })

    def get_queryset(self):
        # pre-select variant and gene data to prevent thousands of queries
        return (
            CurationEntry.objects.authed_curation_set(self.request.user)
            .select_related('owner', 'variant', 'variant__gene', 'disease')
            .prefetch_related(
                'extra_variants',
                'extra_variants__gene',
                'disease'
            )
            .order_by('created_on')
        )


class CurationReviewViewSet(viewsets.ModelViewSet):
    serializer_class = CurationReviewSerializer
    model = CurationReview

    def get_queryset(self):
        queryset = CurationReview.objects.all()
        return queryset

    def get_serializer(self, *args, **kwargs):
        kwargs["many"] = True
        return super(CurationReviewViewSet, self).get_serializer(*args, **kwargs)


# ================================================================================================================
# === SVIP Variant Submission
# ================================================================================================================
# hgvs stuff

## these shared assembly mappers will allow us to convert HGVS g. variants to c. and p. later on
#hdp = hgvs.dataproviders.uta.connect()
#hgnorm = hgvs.normalizer.Normalizer(hdp)
#hgvsparser = hgvs.parser.Parser()
#am = hgvs.assemblymapper.AssemblyMapper(
#    hdp, assembly_name='GRCh37', normalize=True)

#AC_MAP = {
#    '1': 'NC_000001',
#    '2': 'NC_000002',
#    '3': 'NC_000003',
#    '4': 'NC_000004',
#    '5': 'NC_000005',
#    '6': 'NC_000006',
#    '7': 'NC_000007',
#    '8': 'NC_000008',
#    '9': 'NC_000009',
#    '10': 'NC_000010',
#    '11': 'NC_000011',
#    '12': 'NC_000012',
#    '13': 'NC_000013',
#    '14': 'NC_000014',
#    '15': 'NC_000015',
#    '16': 'NC_000016',
#    '17': 'NC_000017',
#    '18': 'NC_000018',
#    '19': 'NC_000019',
#    '20': 'NC_000020',
#    '21': 'NC_000021',
#    '22': 'NC_000022',
#    'X': 'NC_000023',
#    '23': 'NC_000023',
#    'Y': 'NC_000024',
#}


class SubmittedVariantBatchViewSet(viewsets.ModelViewSet):
    permission_classes = (IsSubmitter,)
    serializer_class = SubmittedVariantBatchSerializer
    queryset = SubmittedVariantBatch.objects.order_by('-created_on')


class SubmittedVariantViewSet(viewsets.ModelViewSet):
    filter_backends = (django_filters.rest_framework.DjangoFilterBackend,
                       filters.SearchFilter, filters.OrderingFilter,)
    filter_fields = (
        'chromosome', 'pos', 'ref', 'alt', 'status'
    )
    ordering_fields = filter_fields + \
        ('created_on', 'processed_on', 'batch', 'owner',
         'canonical_only', 'for_curation_request')
    search_fields = ('chromosome', 'pos', 'ref', 'alt',)

    permission_classes = (IsSubmitter,)
    serializer_class = SubmittedVariantSerializer
    queryset = SubmittedVariant.objects.order_by('-created_on')

    @action(methods=['GET'], detail=False)
    def map_hgvs(self, request):
        try:
            # removes all sorts of weird unicode characters that, e.g., SVIP, adds for formatting purposes
            sanitized_hgvs = request.GET['hgvs_str'].strip().encode(
                "ascii", errors='ignore').decode("utf8")
            result = hgvsparser.parse_hgvs_variant(sanitized_hgvs)
            lifted = False

            # if it's not genomic, map it
            if result.type == 'c':
                lifted = True
                result = am.c_to_g(result)
        except HGVSParseError as ex:
            return JsonResponse({'error': str(ex)}, status=status.HTTP_400_BAD_REQUEST)

        return JsonResponse({
            'full_result': str(result),
            'chromosome': next((k for k, v in AC_MAP.items() if result.ac.split(".")[0].startswith(v)), None),
            'pos': result.posedit.pos.start.base,
            'ref': result.posedit.edit.ref,
            'alt': result.posedit.edit.alt,
            'lifted': lifted
        })


# ================================================================================================================
# === Samples
# ================================================================================================================


class SampleViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = SampleSerializer
    permission_classes = (permissions.IsAuthenticated, IsSampleViewer)

    filter_backends = (django_filters.rest_framework.DjangoFilterBackend,
                       filters.SearchFilter, filters.OrderingFilter,)
    filter_fields = (
        'disease_in_svip__disease', 'sample_id', 'year_of_birth', 'gender', 'hospital', 'medical_service', 'provider_annotation',
        'sample_tissue', 'tumor_purity', 'tnm_stage', 'sample_type', 'sample_site', 'specimen_type', 'sequencing_date',
        'panel', 'coverage', 'calling_strategy', 'caller', 'aligner', 'software', 'software_version', 'platform',
        'contact',
    )
    ordering_fields = filter_fields
    search_fields = filter_fields

    def get_queryset(self):
        if not self.request.user.has_perm('api.view_sample'):
            raise PermissionDenied(
                detail="You do not have the necessary permissions to view sample data")

        if 'disease_pk' in self.kwargs and 'variant_in_svip_pk' in self.kwargs:
            q = Sample.objects.filter(
                disease_in_svip_id=self.kwargs['disease_pk'],
                disease_in_svip__svip_variant_id=self.kwargs['variant_in_svip_pk']
            )
        else:
            q = Sample.objects.all()

        return q.order_by('id')

# ================================================================================================================
# === SummaryComment
# ================================================================================================================


class SummaryCommentViewSet(viewsets.ModelViewSet):
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)
    serializer_class = SummaryCommentSerializer

    def get_queryset(self):
        print(f"query params: {self.request.query_params} ")

        variant = self.request.query_params.get('variant')
        owner = self.request.query_params.get('owner')

        queryset = SummaryComment.objects.all()

        if variant is not None:
            queryset = queryset.filter(variant=variant)

        if owner is not None:
            queryset = queryset.filter(owner=owner)

        return queryset
