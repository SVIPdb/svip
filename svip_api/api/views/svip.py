import django_filters
from django import forms
from django.db import models
from django.contrib.postgres.fields import ArrayField, JSONField
from django.db.models import Count, Q
from django.shortcuts import render

# Create your views here.
from django.contrib.auth.models import User, Group
from rest_framework import viewsets, permissions, filters
from django_filters import rest_framework as df_filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.views import APIView

from api.models import (
    VariantInSVIP
)
from api.serializers import (
    VariantInSVIPSerializer
)


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
