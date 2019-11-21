import django_filters
from django.db.models import Prefetch
from django.http import JsonResponse
from rest_framework import viewsets, permissions, filters
from rest_framework.decorators import action
from rest_framework.exceptions import PermissionDenied

from api.models import (
    VariantInSVIP, Sample,
    DiseaseInSVIP,
    CurationEntry,
    Variant
)
from api.permissions import IsCurationPermitted, ALLOW_ANY_CURATOR
from api.serializers import (
    VariantInSVIPSerializer, SampleSerializer
)
from api.serializers.svip import CurationEntrySerializer, DiseaseInSVIPSerializer


# ================================================================================================================
# === Variant Aggregation
# ================================================================================================================

class VariantInSVIPViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Connects a variant, e.g. EGFR L858R, to its SVIP-specific data. Currently that consists of samples
    and curation data, but more will come in the future.
    """
    serializer_class = VariantInSVIPSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)

    def get_queryset(self):
        if 'variant_pk' in self.kwargs:
            q = VariantInSVIP.objects.filter(variant_id=self.kwargs['variant_pk'])
        else:
            q = VariantInSVIP.objects.all().prefetch_related('diseaseinsvip_set', 'diseaseinsvip_set__sample_set')

        return q

    filter_backends = (django_filters.rest_framework.DjangoFilterBackend, filters.SearchFilter,)
    filter_fields = (
        'variant__gene',
        'variant__gene__symbol',
        'variant__name'
    )

    search_fields = (
        'variant__gene__symbol',
        'variant__name',
        'disease__name'
    )


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
            q = DiseaseInSVIP.objects.filter(svip_variant_id=self.kwargs['svip_variant_pk'])
        else:
            q = DiseaseInSVIP.objects.all()
        return q


# ================================================================================================================
# === Curation
# ================================================================================================================

class CurationEntryFilter(django_filters.FilterSet):
    from api.models.svip import CURATION_STATUS
    status_ne = django_filters.ChoiceFilter(
        field_name='status', choices=tuple(CURATION_STATUS.items()),
        lookup_expr='iexact', exclude=True
    )

    class Meta:
        model = CurationEntry
        fields = (
            'owner',
            'disease',
            'variant',
            'extra_variants',
            'status',
            'status_ne'
        )


def authed_curation_set(user):
    result = None

    if user.is_authenticated:
        groups = [x.name for x in user.groups.all()]
        if user.is_superuser:
            # superusers can see everything
            result = CurationEntry.objects.all()
        if 'curators' in groups:
            # curators see only their own entries if ALLOW_ANY_CURATOR is false
            # if it's true, they can see any curation entry
            result = CurationEntry.objects.filter(owner=user) if not ALLOW_ANY_CURATOR else CurationEntry.objects.all()
        elif 'reviewers' in groups:
            # FIXME: should reviewers see all entries, or just the ones they've been assigned?
            result = CurationEntry.objects.filter(status__in=('reviewed', 'submitted'))

    if not result:
        # unauthenticated users and other users who don't have specific roles just see the default set
        result = CurationEntry.objects.filter(status='reviewed')

    return result

class CurationEntryViewSet(viewsets.ModelViewSet):
    """
    Curation entry for a specific variant w/SVIP data and disease.
    """
    serializer_class = CurationEntrySerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly, IsCurationPermitted)

    filter_backends = (django_filters.rest_framework.DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter,)
    filterset_class = CurationEntryFilter
    ordering_fields = '__all__'
    search_fields = (
        'annotations',
        'variant__description',
        'disease__name',
        'comment',
        'drugs',
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
        fullname = ("%s %s" % (obj.first_name, obj.last_name)).strip()
        return fullname if fullname else obj.username

    @action(detail=False, methods=['POST'])
    def bulk_submit(self, request):
        # for every ID in items, if it's saved upgrade it to a draft
        entryIDs = [int(x) for x in request.GET['items'].split(",")]
        result = CurationEntry.objects.filter(id__in=entryIDs, status='saved').update(status='submitted')
        return JsonResponse({
            "input": entryIDs,
            "changed": result
        })

    @action(detail=True)
    def history(self, request, pk):
        entry = CurationEntry.objects.get(id=pk)
        history = list(entry.history.all())
        deltas = (
            {'time': a.history_date, 'diff': a.diff_against(b), 'history_user': self._nice_username(a.history_user)}
            for a, b in zip(history[:-1], history[1:])
        )

        return JsonResponse({
            'created_on': history[0].history_date if len(history) > 0 else None,
            'created_by': self._nice_username(entry.owner),
            'deltas': [
                {
                    'time': str(delta['time']),
                    'changed_by': delta['history_user'],
                    'changes': [
                        {
                            'field': change.field,
                            'old': change.old,
                            'new': change.new
                        }
                        for change in delta['diff'].changes
                    ]
                }
                for delta in deltas
            ]
        })

    def get_queryset(self):
        user = self.request.user
        result = authed_curation_set(user)

        # pre-select variant and gene data to prevent thousands of queries
        result = (
            result
                .select_related('owner')
                .prefetch_related(
                    'variant',
                    Prefetch('extra_variants', queryset=Variant.objects.all().only('id', 'gene_id', 'hgvs_c', 'sources', 'description')),
                    'extra_variants__gene',
                    'disease'
                )
        )

        return result.order_by('created_on')


# ================================================================================================================
# === Samples
# ================================================================================================================

class IsSampleViewer(permissions.BasePermission):
    """
    Allows only individuals with the view_sample permission to view samples.
    """

    def has_object_permission(self, request, view, obj):
        return request.user.has_perm('api.view_sample')


class SampleViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = SampleSerializer
    permission_classes = (permissions.IsAuthenticated, IsSampleViewer)

    filter_backends = (django_filters.rest_framework.DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter,)
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
            raise PermissionDenied(detail="You do not have the necessary permissions to view sample data")

        if 'disease_pk' in self.kwargs and 'variant_in_svip_pk' in self.kwargs:
            q = Sample.objects.filter(
                disease_in_svip_id=self.kwargs['disease_pk'],
                disease_in_svip__svip_variant_id=self.kwargs['variant_in_svip_pk']
            )
        else:
            q = Sample.objects.all()

        return q.order_by('id')
