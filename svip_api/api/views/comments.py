import django_filters
from rest_framework import permissions as drf_permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.viewsets import ModelViewSet

from api import permissions
from api.models.comments import VariantComment
from api.serializers.comments import VariantCommentSerializer


# these tags will exist by default
DEEFAULT_TAGS = (
    "wont-fix",
    "needs-review",
    "incorrectly-classified"
)


class VariantCommentViewSet(ModelViewSet):
    # FIXME: deal with nested comments later; for now, just get top-level ones
    queryset = VariantComment.objects.filter(parent__isnull=True)
    serializer_class = VariantCommentSerializer
    permission_classes = (drf_permissions.IsAuthenticated, permissions.IsOwnerOrReadOnly)

    filter_backends = (django_filters.rest_framework.DjangoFilterBackend,)
    filter_fields = (
        'variant',
    )

    @action(detail=False)
    def tagtypes(self, request):
        """
        Gets the (unique) set of tags declared on any VariantComment.
        """

        # FIXME: do the array merge + deduplication in SQL instead of in python, b/c there's no way the below will scale

        return Response(
            sorted(set([
                tag for tags in VariantComment.objects.values_list('tags', flat=True) for tag in tags
            ] + list(DEEFAULT_TAGS)))
        )
