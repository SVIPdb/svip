import django_filters
import hgvs.assemblymapper
import hgvs.dataproviders.uta
import hgvs.normalizer
import hgvs.parser
from django.contrib.auth.models import User
from django.contrib.postgres.aggregates import ArrayAgg
from django.db.models import Prefetch, Q
from django.http import JsonResponse
from hgvs.exceptions import HGVSParseError
from rest_framework import viewsets, permissions, filters, status
from rest_framework.decorators import action
from rest_framework.exceptions import PermissionDenied
from rest_framework.response import Response
from rest_framework.views import APIView

from api.models import (
    VariantInSVIP, Sample,
    DiseaseInSVIP,
    CurationEntry,
    Disease, Variant,
    Gene
)
from api.models.svip import (
    SubmittedVariant, SubmittedVariantBatch, CurationRequest, SummaryComment, CurationReview,
    SummaryDraft, GeneSummaryDraft, SubmissionEntry
)
from api.permissions import IsCurationPermitted, IsSampleViewer, IsSubmitter
from api.serializers import (
    VariantInSVIPSerializer, SampleSerializer
)
from api.serializers.svip import (
    CurationEntrySerializer, DiseaseInSVIPSerializer, SubmittedVariantBatchSerializer, SubmittedVariantSerializer,
    CurationRequestSerializer, SummaryCommentSerializer,
    CurationReviewSerializer, SummaryDraftSerializer, GeneSummaryDraftSerializer,
    SubmissionEntrySerializer
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
            )),
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
        field_name='status', choices=CURATION_STATUS.get_choices(),
        lookup_expr='iexact', exclude=True
    )
    variant_ref = django_filters.NumberFilter(method='any_variant_ref')

    @staticmethod
    def any_variant_ref(queryset, name, value):
        return queryset.filter(Q(variant_id=value))
        # return queryset.filter(Q(variant_id=value) | Q(extra_variants=value))

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
        'escat_score',
        'short_escat_score',
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
            id__in=entryIDs, status='saved').update(status='ready_for_submission')
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


class SubmissionEntryViewSet(viewsets.ModelViewSet):
    """
    View for manage submission entries
    """
    serializer_class = SubmissionEntrySerializer
    permission_classes = (permissions.IsAuthenticated, IsCurationPermitted)
    filter_backends = (django_filters.rest_framework.DjangoFilterBackend,
                       filters.SearchFilter, filters.OrderingFilter,)
    filter_fields = (
        'disease', 'variant', 'effect', 'drug', 'tier', 'type_of_evidence'
    )
    ordering_fields = filter_fields
    search_fields = filter_fields
    queryset = SubmissionEntry.objects.all()

    def get_queryset(self):
        if self.request.GET.get('variant_id'):
            return self.queryset.filter(variant=self.request.GET.get('variant_id'))
        return self.queryset

    def perform_create(self, serializer):
        """Create a new recipe."""
        serializer.save(user=self.request.user)

    @action(detail=False, methods=['POST'])
    def bulk_submit(self, request):

        if isinstance(request.data, dict) and request.data['update']:
            for entry in request.data['data']:
                submission_entry = SubmissionEntry.objects.filter(pk=entry['id'])
                submission_entry.update(effect=entry['effect'], tier=entry['tier'])
                for id in entry['curation_entries']:
                    CurationEntry.objects.filter(pk=id).update(status='resubmitted')
                for id in entry['curation_reviews']:
                    CurationReview.objects.get(pk=id).delete()
            return JsonResponse({
                "message": "Your second annotation  was successfully saved!",

            })

        for item in request.data:
            disease = None
            if item['disease_id']:
                disease = Disease.objects.get(id=item['disease_id'])
            submission_entry = SubmissionEntry(variant=Variant.objects.get(pk=item['variant_id']),
                                               owner=User.objects.get(id=item['owner_id']),
                                               drug=item['drug'],
                                               type_of_evidence=item['type_of_evidence'],
                                               effect=item['effect'],
                                               tier=item['tier'],
                                               disease=disease)
            submission_entry.save()

            for entry_id in item['curation_entries']:
                CurationEntry.objects.filter(pk=entry_id).update(status='submitted',
                                                                 submission_entry=submission_entry)

        return JsonResponse({
            "message": "Curations were successfully saved!",

        })


class CurationReviewViewSet(viewsets.ModelViewSet):
    permission_classes = (permissions.IsAuthenticated,)
    serializer_class = CurationReviewSerializer
    model = CurationReview

    def __save_review_obj(self, obj):

        if 'id' in obj:
            review = CurationReview.objects.get(id=obj['id'])
        else:
            review = CurationReview()
        review.submission_entry = SubmissionEntry.objects.get(id=obj['submission_entry'])
        review.annotated_effect = obj['effect']
        review.annotated_tier = obj['tier']
        review.comment = obj['comment']
        review.draft = obj['draft']
        review.reviewer = User.objects.get(id=obj['reviewer'])
        review.acceptance = obj['acceptance']
        review.save()

    def get_queryset(self):
        queryset = CurationReview.objects.all()
        return queryset

    @action(detail=False, methods=['POST'])
    def submit_review(self, request):
        self.__save_review_obj(request.data)
        return Response(data='Submitted reviews are succesfully saved', status=status.HTTP_201_CREATED)

    @action(detail=False, methods=['POST'])
    def bulk_submit(self, request):
        for item in request.data['data']:
            for obj in item[1]:
                self.__save_review_obj(obj)
        return Response(data='Submitted reviews are succesfully saved', status=status.HTTP_201_CREATED)


# ================================================================================================================
# === SVIP Variant Submission
# ================================================================================================================
# hgvs stuff

# these shared assembly mappers will allow us to convert HGVS g. variants to c. and p. later on
hdp = hgvs.dataproviders.uta.connect()
hgnorm = hgvs.normalizer.Normalizer(hdp)
hgvsparser = hgvs.parser.Parser()
am = hgvs.assemblymapper.AssemblyMapper(
    hdp, assembly_name='GRCh37', normalize=True)

AC_MAP = {
    '1': 'NC_000001',
    '2': 'NC_000002',
    '3': 'NC_000003',
    '4': 'NC_000004',
    '5': 'NC_000005',
    '6': 'NC_000006',
    '7': 'NC_000007',
    '8': 'NC_000008',
    '9': 'NC_000009',
    '10': 'NC_000010',
    '11': 'NC_000011',
    '12': 'NC_000012',
    '13': 'NC_000013',
    '14': 'NC_000014',
    '15': 'NC_000015',
    '16': 'NC_000016',
    '17': 'NC_000017',
    '18': 'NC_000018',
    '19': 'NC_000019',
    '20': 'NC_000020',
    '21': 'NC_000021',
    '22': 'NC_000022',
    'X': 'NC_000023',
    '23': 'NC_000023',
    'Y': 'NC_000024',
}


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
        'disease_in_svip__disease', 'sample_id', 'year_of_birth', 'gender', 'hospital', 'medical_service',
        'provider_annotation',
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

        variant = self.request.query_params.get('variant')
        owner = self.request.query_params.get('owner')

        queryset = SummaryComment.objects.all()

        if variant is not None:
            queryset = queryset.filter(variant=variant)

        if owner is not None:
            queryset = queryset.filter(owner=owner)

        return queryset


class SummaryDraftViewSet(viewsets.ModelViewSet):
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)
    serializer_class = SummaryDraftSerializer

    def get_queryset(self):
        variant = self.request.query_params.get('variant')
        owner = self.request.query_params.get('owner')
        queryset = SummaryDraft.objects.all()

        if variant is not None:
            queryset = queryset.filter(variant=variant)

        if owner is not None:
            queryset = queryset.filter(owner=owner)

        return queryset


class GeneSummaryDraftViewSet(viewsets.ModelViewSet):
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)
    serializer_class = GeneSummaryDraftSerializer

    def get_queryset(self):
        gene = self.request.query_params.get('gene')
        owner = self.request.query_params.get('owner')
        queryset = GeneSummaryDraft.objects.all()

        if gene is not None:
            queryset = queryset.filter(gene=gene)

        if owner is not None:
            queryset = queryset.filter(owner=owner)

        return queryset


class CurationIds(APIView):

    # returns all the IDs of the curation associated with the current variant
    def post(self, request, *args, **kwargs):
        var_id = request.data.get('var_id')
        curations = {}

        for curation in Variant.objects.get(id=var_id).curation_entries.all():
            curations[curation.id] = True

        return Response(data=curations)


class UpdateVariantSummary(APIView):
    def post(self, request, *args, **kwargs):
        var_id = kwargs.get('var_id')
        summary = request.data.get('summary')
        summary_draft_id = request.data.get('summary_draft_id')

        summary_draft = SummaryDraft.objects.get(id=summary_draft_id)

        if var_id == None:
            svip_var, svip_created = VariantInSVIP.objects.get_or_create(
                variant=summary_draft.variant
            )
        else:
            svip_var = VariantInSVIP.objects.get(id=var_id)

        svip_var.summary = summary
        if 'summary_date' in request.data:
            svip_var.summary_date = request.data.get('summary_date')
        svip_var.save()

        summary_draft.delete()
        return Response(data=f"""The summary of VariantInSVIP {var_id} is updated. 
                        The SummaryDraft {summary_draft_id} is deleted.
                        """)


class UpdateGeneSummary(APIView):
    def post(self, request, *args, **kwargs):
        gene_id = request.data.get('gene_id')
        summary = request.data.get('summary')
        summary_draft_id = request.data.get('summary_draft_id')

        gene = Gene.objects.get(id=gene_id)
        gene.summary = summary
        if 'summary_date' in request.data:
            gene.summary_date = request.data.get('summary_date')
        gene.save()

        GeneSummaryDraft.objects.get(id=summary_draft_id).delete()
        return Response(data=f"""The summary of Gene {gene_id} is updated. 
                        The SummaryDraft {summary_draft_id} is deleted.
                        """)
