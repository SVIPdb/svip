"""
Serializers for SVIP-specific models.
"""
import datetime
from itertools import chain

from django.db.models import Count
from rest_framework import serializers
from rest_framework.reverse import reverse
from rest_framework_nested.relations import NestedHyperlinkedRelatedField, NestedHyperlinkedIdentityField
from rest_framework_nested.serializers import NestedHyperlinkedModelSerializer

from api.models import VariantInSVIP, Sample, CurationEntry
from api.models.svip import Disease, DiseaseInSVIP

from django.contrib.auth import get_user_model
User = get_user_model()


class SampleSerializer(serializers.ModelSerializer):
    disease_name = serializers.SerializerMethodField()

    @staticmethod
    def get_disease_name(obj):
        return obj.disease_in_svip.disease.name

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
        return [
            DiseaseInSVIPSerializer(x, context={'request': self.context['request']}).data
            for x in obj.diseaseinsvip_set.all()
        ]

    class Meta:
        model = VariantInSVIP
        fields = (
            'url',
            'id',
            'variant',
            'tissue_counts',
            'diseases'
        )


class DiseaseInSVIPSerializer(NestedHyperlinkedModelSerializer):
    parent_lookup_kwargs = {
        'variant_in_svip_pk': 'svip_variant__pk',
        'pk': 'pk',
    }

    nb_patients = serializers.SerializerMethodField()
    gender_balance = serializers.SerializerMethodField()
    age_distribution = serializers.SerializerMethodField()

    # samples = serializers.SerializerMethodField()
    curation_entries = serializers.SerializerMethodField()

    # samples_url = serializers.SerializerMethodField()
    # samples_url = NestedHyperlinkedRelatedField(
    #     many=True,
    #     read_only=True,   # Or add a queryset
    #     view_name='disease-samples-detail',
    #     parent_lookup_kwargs={'disease_pk': 'disease__pk'}
    # )

    class SamplesHyperlinkedIdentityField(serializers.HyperlinkedIdentityField):
        def get_url(self, obj, view_name, request, format):
            """
            Given an object, return the URL that hyperlinks to the object.
            May raise a `NoReverseMatch` if the `view_name` and `lookup_field`
            attributes are not configured to correctly match the URL conf.
            """
            # Unsaved objects will not yet have a valid URL.
            if obj.pk is None:
                return None

            return self.reverse(view_name,
                                kwargs={
                                    'disease_pk': obj.id,
                                    'variant_in_svip_pk': obj.svip_variant.id,
                                },
                                request=request,
                                format=format,
                                )

    samples_url = SamplesHyperlinkedIdentityField(view_name='sample-list')

    age_brackets = {
        "<40": lambda x: x < 40,
        ">80": lambda x: x > 80,
        "41-60": lambda x: 41 <= x <= 60,
        "61-80": lambda x: 61 <= x <= 80
    }

    def get_nb_patients(self, obj):
        return obj.sample_set.count()

    def get_gender_balance(self, obj):
        result = dict(
            (x['gender'].lower(), x['count'])
                for x in obj.sample_set.values('gender').annotate(count=Count('gender'))
        )

        # ensure each gender is represented
        if 'male' not in result:
            result['male'] = 0
        if 'female' not in result:
            result['female'] = 0

        return result

    def get_age_distribution(self, obj):
        # produce the age brackets merged with the number of age entries that match each bracket
        curYear = datetime.datetime.now().year
        ages = [curYear - int(x[0]) for x in obj.sample_set.values_list('year_of_birth')]
        return dict(
            (bracket, sum(1 for x in ages if bracket_pred(x)))
                for bracket, bracket_pred in DiseaseInSVIPSerializer.age_brackets.items()
        )

    def get_samples(self, obj):
        user = self.context['request'].user
        if not user.has_perm('api.view_sample'):
            return []

        return [
            SampleSerializer(x).data
            for x in obj.sample_set.all()
        ]

    def get_curation_entries(self, obj):
        # FIXME: correctly determine permissions for viewing curation entries
        return [
            CurationEntrySerializer(x).data
            for x in obj.curation_entries().all()
        ]

    class Meta:
        model = DiseaseInSVIP
        fields = (
            'id',
            'samples_url',
            'name',
            'sample_diseases_count',

            'status',
            'score',
            'pathogenic',
            'clinical_significance',

            'nb_patients',
            'gender_balance',
            'age_distribution',

            # 'samples',
            'curation_entries'
        )