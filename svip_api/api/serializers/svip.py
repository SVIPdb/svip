"""
Serializers for SVIP-specific models.
"""
import datetime

from django.db.models import Count
from rest_framework import serializers
from rest_framework.reverse import reverse

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
    # samples = serializers.SerializerMethodField()
    # curation_entries = serializers.SerializerMethodField()

    samples_url = serializers.SerializerMethodField()

    age_brackets = {
        "<40": lambda x: x < 40,
        ">80": lambda x: x > 80,
        "41-60": lambda x: 41 <= x <= 60,
        "61-80": lambda x: 61 <= x <= 80
    }

    def get_samples_url(self, obj):
        # FIXME: ideally, this should link by reference to the samples nested router, but we're hardcoding it here
        #  because i can't figure out how to do that :\
        our_url = reverse('variantinsvip-detail', args=[obj.id], request=self.context['request'])
        return "%s/samples" % our_url

    @staticmethod
    def get_diseases(obj):
        template = obj.data['diseases']
        # override specific entries in the template (for now)
        for entry in template:
            disease_set = obj.sample_set.filter(disease__iexact=entry['name'])
            entry['nb_patients'] = disease_set.count()
            entry['gender_balance'] = dict(
                (x['gender'].lower(), x['count'])
                for x in disease_set.values('gender').annotate(count=Count('gender'))
            )

            # produce the age brackets merged with the number of age entries that match each bracket
            curYear = datetime.datetime.now().year
            ages = [curYear - int(x[0]) for x in obj.sample_set.values_list('year_of_birth')]
            entry['age_distribution'] = dict(
                (bracket, sum(1 for x in ages if bracket_pred(x)))
                for bracket, bracket_pred in VariantInSVIPSerializer.age_brackets.items()
            )
        return template

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
            'url',
            'id',
            'samples_url',
            'sample_count',
            'sample_diseases_count',
            'tissue_counts',
            'diseases'
        )
