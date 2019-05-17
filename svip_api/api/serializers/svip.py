"""
Serializers for SVIP-specific models.
"""
import datetime
from itertools import chain

from django.db.models import Count
from rest_framework import serializers
from rest_framework.reverse import reverse

from api.models import VariantInSVIP, Sample, CurationEntry
from api.models.svip import Disease


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

    def get_diseases(self, obj):
        return [DiseaseSerializer(x, context={'request': self.context['request']}).data for x in obj.disease_set.all()]

    class Meta:
        model = VariantInSVIP
        fields = (
            'url',
            'id',
            'tissue_counts',
            'diseases'
        )


class DiseaseSerializer(serializers.ModelSerializer):
    nb_patients = serializers.SerializerMethodField()
    gender_balance = serializers.SerializerMethodField()
    age_distribution = serializers.SerializerMethodField()

    samples = serializers.SerializerMethodField()
    curation_entries = serializers.SerializerMethodField()

    # samples_url = serializers.SerializerMethodField()

    age_brackets = {
        "<40": lambda x: x < 40,
        ">80": lambda x: x > 80,
        "41-60": lambda x: 41 <= x <= 60,
        "61-80": lambda x: 61 <= x <= 80
    }

    def get_nb_patients(self, obj):
        return obj.sample_set.count()

    def get_gender_balance(self, obj):
        return dict(
            (x['gender'].lower(), x['count'])
                for x in obj.sample_set.values('gender').annotate(count=Count('gender'))
        )

    def get_age_distribution(self, obj):
        # produce the age brackets merged with the number of age entries that match each bracket
        curYear = datetime.datetime.now().year
        ages = [curYear - int(x[0]) for x in obj.sample_set.values_list('year_of_birth')]
        return dict(
            (bracket, sum(1 for x in ages if bracket_pred(x)))
                for bracket, bracket_pred in DiseaseSerializer.age_brackets.items()
        )

    # def get_samples_url(self, obj):
    #     # FIXME: ideally, this should link by reference to the samples nested router, but we're hardcoding it here
    #     #  because i can't figure out how to do that :\
    #     our_url = reverse('variantinsvip-detail', args=[obj.id], request=self.context['request'])
    #     return "%s/samples" % our_url

    def get_samples(self, obj):
        user = self.context['request'].user
        if not user.has_perm('api.view_sample'):
            return []

        return [
            SampleSerializer(x).data
            for x in obj.sample_set.all()
        ]

    def get_curation_entries(self, obj):
        # user = self.context['request'].user
        # if not user.has_perm('api.view_curationentry'):
        #     return []

        return [
            CurationEntrySerializer(x).data
            for x in obj.curationentry_set.all()
        ]

    class Meta:
        model = Disease
        fields = (
            # 'url',
            # 'id',
            # 'samples_url',
            'name',
            'sample_diseases_count',

            'status',
            'score',
            'pathogenic',
            'clinical_significance',

            'nb_patients',
            'gender_balance',
            'age_distribution',

            'samples',
            'curation_entries'
        )