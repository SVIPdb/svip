"""
Serializers for SVIP-specific models.
"""
import datetime
from itertools import chain

from django.db.models import Count
from django.utils.timezone import now
from rest_framework import serializers
from rest_framework.reverse import reverse
from rest_framework_nested.relations import NestedHyperlinkedRelatedField, NestedHyperlinkedIdentityField
from rest_framework_nested.serializers import NestedHyperlinkedModelSerializer

from api.models import VariantInSVIP, Sample, CurationEntry, Variant
from api.models.svip import Disease, DiseaseInSVIP, CURATION_STATUS

from django.contrib.auth import get_user_model

from api.permissions import IsCurationPermitted
from api.utils import format_variant

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
    owner = serializers.PrimaryKeyRelatedField(default=serializers.CurrentUserDefault(), queryset=User.objects.all())
    status = serializers.ChoiceField(choices=tuple(CURATION_STATUS.items()))
    created_on = serializers.DateTimeField(read_only=True, default=now)

    owner_name = serializers.SerializerMethodField()
    formatted_variants = serializers.SerializerMethodField()

    @staticmethod
    def get_owner_name(obj):
        fullname = ("%s %s" % (obj.owner.first_name, obj.owner.last_name)).strip()
        return fullname if fullname else obj.owner.username

    @staticmethod
    def get_formatted_variants(obj):
        return [format_variant(x) for x in obj.variants.all()]

    def save(self, **kwargs):
        # force owner to be the current user
        # FIXME: we should include a caveat for superusers
        # TODO: use stricter validation if the status isn't 'draft'
        kwargs["owner"] = self.fields["owner"].get_default()
        return super().save(**kwargs)

    def validate(self, data):
        if data['status'] != 'draft':
            # TODO: perform more stringent validation
            # FIXME: for now we'll do validation here, but ideally it should be factored out
            non_empty_fields = (
                'disease',
                'variants',

                'type_of_evidence',
                'effect',
                'tier_level_criteria',
                'mutation_origin',

                'support',
                # 'comment'
                # 'references',
            )

            # holds all errors that've been detected so far
            errors = {}

            empty_fields = [k for k in non_empty_fields if k not in data or data[k] in ('', None)]

            if len(empty_fields) > 0:
                errors.update(dict(
                    (k, "Field '%s' cannot be null or empty" % k) for k in empty_fields
                ))

            # also ensure that drug is specified if the type_of_evidence is "Predictive / Therapeutic"
            if data['type_of_evidence'] == "Predictive / Therapeutic" and ('drug' not in data or data['drug'] in ('', None)):
                errors.update({'drug': "Field 'drug' cannot be null or empty if type_of_evidence is predictive"})

            if len(errors) > 0:
                raise serializers.ValidationError(errors)


        return super().validate(data)

    class Meta:
        model = CurationEntry
        fields = (
            'id',
            'disease',
            'variants',

            'type_of_evidence',
            'drug',
            'effect',
            'tier_level_criteria',
            'tier_level',
            'mutation_origin',
            'summary',
            'support',
            'comment',
            'references',
            'annotations',

            'created_on',
            'last_modified',
            'owner',
            'owner_name',
            'formatted_variants',
            'status',
        )


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

            return self.reverse(
                view_name,
                kwargs={'disease_pk': obj.id, 'variant_in_svip_pk': obj.svip_variant.id},
                request=request, format=format
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
            if IsCurationPermitted.is_user_allowed(user=self.context['request'].user, obj=x, is_reading=True)
        ]

    class Meta:
        model = DiseaseInSVIP
        fields = (
            'id',
            'disease_id',
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