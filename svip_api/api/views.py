from django.shortcuts import render

# Create your views here.
from django.contrib.auth.models import User, Group
from rest_framework import viewsets, permissions

from api.models import Gene, Variant, Association, Phenotype, Evidence, EnvironmentalContext
from api.serializers import UserSerializer, GroupSerializer, GeneSerializer, \
    VariantSerializer, AssociationSerializer, \
    PhenotypeSerializer, EvidenceSerializer, EnvironmentalContextSerializer


# svip data endpoints

class GeneViewSet(viewsets.ModelViewSet):
    """
    Genes that we've discovered from harvesting.
    """
    queryset = Gene.objects.all().order_by('symbol')
    serializer_class = GeneSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)


class VariantViewSet(viewsets.ModelViewSet):
    """
    Genetic variants that are associated to particular genes.

    This can include coding variants as well as more generic
    "features", e.g. fusions between genes and amplifications.
    """
    queryset = Variant.objects.all().order_by('name')
    serializer_class = VariantSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)


class AssociationViewSet(viewsets.ModelViewSet):
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


class PhenotypeViewSet(viewsets.ModelViewSet):
    """
    A visible effect of the variant, e.g. a disease state.
    """
    queryset = Phenotype.objects.all().order_by('id')
    serializer_class = PhenotypeSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)


class EvidenceViewSet(viewsets.ModelViewSet):
    """
    Supporting information for the conclusion forwarded by the
    association. This might include literature references, treatment
    advice,
    """
    queryset = Evidence.objects.all().order_by('id')
    serializer_class = EvidenceSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)


class EnvironmentalContextViewSet(viewsets.ModelViewSet):
    """
    API endpoint for viewing genes
    """
    queryset = EnvironmentalContext.objects.all().order_by('id')
    serializer_class = EnvironmentalContextSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)
