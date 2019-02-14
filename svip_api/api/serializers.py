from django.contrib.auth.models import User, Group
from rest_framework import serializers

from api.models import Gene, Variant, Association, Phenotype, Evidence, EnvironmentalContext


# -----------------------------------------------------------------------------
# --- app management serializers
# -----------------------------------------------------------------------------

class UserSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = User
        fields = ('url', 'username', 'email', 'groups')


class GroupSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Group
        fields = ('url', 'name')


# -----------------------------------------------------------------------------
# --- genomics-related serializers
# -----------------------------------------------------------------------------

class GeneSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Gene
        fields = '__all__'


class PhenotypeSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Phenotype
        fields = '__all__'


class EvidenceSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Evidence
        fields = '__all__'


class EnvironmentalContextSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = EnvironmentalContext
        fields = '__all__'


class AssociationSerializer(serializers.HyperlinkedModelSerializer):
    # phenotype_set = PhenotypeSerializer(read_only=True)
    # evidence_set = EvidenceSerializer(read_only=True)
    # environmentalcontext_set = EnvironmentalContextSerializer(read_only=True)

    class Meta:
        model = Association
        depth = 1
        fields = (
            'url',
            # 'gene',
            # 'variant',
            'source_url',
            'source',
            'description',
            'drug_labels',
            'variant_name',
            'source_link',
            'evidence_label',
            'response_type',
            'evidence_level',
            'phenotype_set',
            'evidence_set',
            'environmentalcontext_set',
        )


class VariantSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Variant
        # fields = (
        #     'url',
        #     'gene',
        #     'name',
        #     'description',
        #     'biomarker_type',
        #     'so_hierarchy',
        #     'soid',
        #     'so_name',
        #     'sources',
        #     'association_set'
        # )

        fields = [field.name for field in model._meta.fields]
        fields.append('url')
        fields.append('gene')
        fields.append('gene_symbol')
        fields.append('association_set')
        fields.remove('mv_info')  # redacted in the list view because it's too verbose


class FullVariantSerializer(VariantSerializer):
    association_set = AssociationSerializer(many=True)

    def __init__(self, *args, **kwargs):
        super(FullVariantSerializer, self).__init__(*args, **kwargs)

    class Meta:
        model = Variant
        depth = 1
        fields = VariantSerializer.Meta.fields.copy()
        fields.append('mv_info')
