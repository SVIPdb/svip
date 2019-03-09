from django.contrib.auth.models import User, Group
from rest_framework import serializers

from api.models import Source, Gene, Variant, Association, Phenotype, Evidence, EnvironmentalContext, VariantInSource


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

class SourceSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Source
        fields = '__all__'


class GeneSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Gene
        fields = '__all__'


class VariantInSourceSerializer(serializers.HyperlinkedModelSerializer):
    variant = serializers.HyperlinkedRelatedField('variant-detail', read_only=True)
    source = SourceSerializer()
    # associations = serializers.HyperlinkedRelatedField('assocation-detail', read_only=True, many=True)

    class Meta:
        model = VariantInSource
        fields = (
            'variant',
            'source',
            'variant_url',
            'extras',
            'association_set',
            'url'
        )


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

            'evidence_type',
            'evidence_direction',
            'clinical_significance',
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
        fields.remove('mv_info')  # redacted in the list view because it's too verbose

        # FIXME: add sources collection here, from VariantInSource


class FullVariantSerializer(VariantSerializer):
    # sources_set = VariantInSourceSerializer(many=True)
    variantinsource_set = VariantInSourceSerializer(many=True, read_only=True)

    def __init__(self, *args, **kwargs):
        super(FullVariantSerializer, self).__init__(*args, **kwargs)

    class Meta:
        model = Variant
        depth = 1
        fields = VariantSerializer.Meta.fields.copy()
        fields.append('mv_info')
        fields.append('variantinsource_set')
