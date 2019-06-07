import django_filters
from rest_framework import viewsets, permissions, filters
from rest_framework.exceptions import PermissionDenied
from api.models import (
    VariantInSVIP, Sample,
    Disease
)
from api.serializers import (
    VariantInSVIPSerializer, SampleSerializer
)
from api.serializers.svip import DiseaseSerializer


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
            q = VariantInSVIP.objects.all()
        return q


class DiseaseViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Connects a variant, e.g. EGFR L858R, to its SVIP-specific data. Currently that consists of samples
    and curation data, but more will come in the future.
    """
    serializer_class = DiseaseSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)

    def get_queryset(self):
        if 'svip_variant_pk' in self.kwargs:
            q = Disease.objects.filter(svip_variant_id=self.kwargs['svip_variant_pk'])
        else:
            q = Disease.objects.all()
        return q


class IsSampleViewer(permissions.BasePermission):
    """
    Custom permission to only allow owners of an object to edit it.
    """

    def has_object_permission(self, request, view, obj):
        return request.user.has_perm('api.view_sample')


class SampleViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = SampleSerializer
    permission_classes = (permissions.IsAuthenticated, IsSampleViewer)

    filter_backends = (django_filters.rest_framework.DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter,)
    filter_fields = (
        'disease',
    )
    ordering_fields = (
        'disease',
        'sample_id',
        'year_of_birth',
        'gender',
        'hospital',
        'medical_service',
        'provider_annotation',
        'sample_tissue',
        'tumor_purity',
        'tnm_stage',
        'sample_type',
        'sample_site',
        'specimen_type',
        'sequencing_date',
        'panel',
        'coverage',
        'calling_strategy',
        'caller',
        'aligner',
        'software',
        'software_version',
        'platform',
        'contact',
    )
    search_fields = (
        'disease',
        'sample_id',
        'year_of_birth',
        'gender',
        'hospital',
        'medical_service',
        'provider_annotation',
        'sample_tissue',
        'tumor_purity',
        'tnm_stage',
        'sample_type',
        'sample_site',
        'specimen_type',
        'sequencing_date',
        'panel',
        'coverage',
        'calling_strategy',
        'caller',
        'aligner',
        'software',
        'software_version',
        'platform',
        'contact',
    )

    def get_queryset(self):
        if not self.request.user.has_perm('api.view_sample'):
            raise PermissionDenied(detail="You do not have the necessary permissions to view sample data")

        if 'disease_pk' in self.kwargs and 'variant_in_svip_pk' in self.kwargs:
            q = Sample.objects.filter(disease_id=self.kwargs['disease_pk'], disease__svip_variant__id=self.kwargs['variant_in_svip_pk'])
        else:
            q = Sample.objects.all()

        return q.order_by('id')
