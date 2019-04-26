"""
Serializers for SVIP-specific models.
"""
from rest_framework import serializers

from api.models import VariantInSVIP, Sample, CurationEntry


class SampleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Sample
        fields = '__all__'


class CurationEntrySerializer(serializers.ModelSerializer):
    class Meta:
        model = CurationEntry
        fields = '__all__'


class VariantInSVIPSerializer(serializers.HyperlinkedModelSerializer):
    diseases = serializers.SerializerMethodField()
    samples = serializers.SerializerMethodField()
    curation_entries = serializers.SerializerMethodField()

    @staticmethod
    def get_diseases(obj):
        return obj.data['diseases']

    @staticmethod
    def get_samples(obj):
        return [
            SampleSerializer(x).data
            for x in obj.sample_set.all()
        ]

    @staticmethod
    def get_curation_entries(obj):
        return [
            CurationEntrySerializer(x).data
            for x in obj.curationentry_set.all()
        ]

    class Meta:
        model = VariantInSVIP
        fields = (
            ''
            'diseases', 'samples', 'curation_entries'
        )
