from rest_framework.fields import SerializerMethodField

from api.models import Variant
from api.serializers.genomic import VariantSerializer, VariantInSourceSerializer, GeneSerializer
from api.serializers.svip import VariantInSVIPSerializer


class FullVariantSerializer(VariantSerializer):
    # sources_set = VariantInSourceSerializer(many=True)
    variantinsource_set = VariantInSourceSerializer(many=True, read_only=True)

    # svip_data = VariantInSVIPSerializer()
    svip_data = SerializerMethodField()

    def get_svip_data(self, obj):
        if not hasattr(obj, 'variantinsvip') or not obj.variantinsvip:
            return None

        return VariantInSVIPSerializer(
            obj.variantinsvip, many=False, context={'request': self.context['request']}
        ).data

    def __init__(self, *args, **kwargs):
        super(FullVariantSerializer, self).__init__(*args, **kwargs)

    class Meta:
        model = Variant
        depth = 1
        fields = VariantSerializer.Meta.fields.copy()
        fields.append('mv_info')
        fields.append('variantinsource_set')
        fields.append('svip_data')


class OnlySVIPVariantSerializer(VariantSerializer):
    # sources_set = VariantInSourceSerializer(many=True)
    # svip_data = VariantInSVIPSerializer(many=True)
    svip_data = SerializerMethodField()
    gene = GeneSerializer()

    def get_svip_data(self, obj):
        if not hasattr(obj, 'variantinsvip') or not obj.variantinsvip:
            return None

        return VariantInSVIPSerializer(
            obj.variantinsvip, many=False, context={'request': self.context['request']}
        ).data

    def __init__(self, *args, **kwargs):
        super(OnlySVIPVariantSerializer, self).__init__(*args, **kwargs)

    class Meta:
        model = Variant
        depth = 1
        fields = VariantSerializer.Meta.fields.copy()
        fields.append('gene')
        fields.append('svip_data')
