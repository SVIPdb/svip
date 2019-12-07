import django_filters
from rest_framework import permissions
from rest_framework.viewsets import ModelViewSet

from api.models.comments import VariantComment, VariantTag
from api.serializers.comments import VariantCommentSerializer, VariantTagSerializer


class VariantCommentViewSet(ModelViewSet):
    queryset = VariantComment.objects.all()
    serializer_class = VariantCommentSerializer
    permission_classes = (permissions.IsAuthenticated,)

    filter_backends = (django_filters.rest_framework.DjangoFilterBackend,)
    filter_fields = (
        'variant',
    )


class VariantTagViewSet(ModelViewSet):
    queryset = VariantTag.objects.all()
    serializer_class = VariantTagSerializer
    permission_classes = (permissions.IsAuthenticated,)
