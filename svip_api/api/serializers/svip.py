"""
Serializers for SVIP-specific models.
"""
import datetime
from itertools import chain
from pprint import pprint

from django.db.models import Count, Q, F, Value
from django.db.models.functions import Concat
from django.utils.functional import cached_property
from django.utils.timezone import now
from rest_framework import serializers
from rest_framework.reverse import reverse
from rest_framework_nested.relations import NestedHyperlinkedRelatedField, NestedHyperlinkedIdentityField
from rest_framework_nested.serializers import NestedHyperlinkedModelSerializer

from api.models import VariantInSVIP, Sample, CurationEntry, Variant
from api.models.svip import Disease, DiseaseInSVIP, CURATION_STATUS

from django.contrib.auth import get_user_model

from api.permissions import IsCurationPermitted, authed_curation_set
from api.serializers import SimpleVariantSerializer
from api.serializers.reference import DiseaseSerializer
from api.shared import pathogenic, clinical_significance
from api.utils import format_variant, field_is_empty

User = get_user_model()


# ================================================================================================================
# === Variant Aggregation
# ================================================================================================================

class VariantInSVIPSerializer(serializers.HyperlinkedModelSerializer):
    diseases = serializers.SerializerMethodField()

    def get_diseases(self, obj):
        qset = (
            obj.diseaseinsvip_set
                .select_related('disease')
                .prefetch_related('sample_set', 'disease__curationentry_set')
                .all()
        )
        return [
            DiseaseInSVIPSerializer(x, context={'request': self.context['request']}).data
            for x in qset
        ]

    class Meta:
        model = VariantInSVIP
        fields = (
            'url',
            'id',
            'variant',
            'summary',
            'tissue_counts',
            'diseases'
        )


# ================================================================================================================
# === Disease Aggregation
# ================================================================================================================

class DiseaseInSVIPSerializer(NestedHyperlinkedModelSerializer):
    parent_lookup_kwargs = {
        'variant_in_svip_pk': 'svip_variant__pk',
        'pk': 'pk',
    }

    nb_patients = serializers.SerializerMethodField()
    gender_balance = serializers.SerializerMethodField()
    age_distribution = serializers.SerializerMethodField()

    # samples = serializers.SerializerMethodField()
    # sample_count = serializers.SerializerMethodField()
    curation_entries = serializers.SerializerMethodField()
    sample_diseases_count = serializers.SerializerMethodField()
    pathogenic = serializers.SerializerMethodField()
    clinical_significance = serializers.SerializerMethodField()

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

    @staticmethod
    def get_nb_patients(obj):
        return obj.sample_set.count()

    @staticmethod
    def get_gender_balance(obj):
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

    @staticmethod
    def get_age_distribution(obj):
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

    @cached_property
    def _authed_curation_set(self):
        return authed_curation_set(self.context['request'].user)

    def _curation_entries(self, obj):
        # authed_set = CurationEntry.objects.all()

        # in addition to getting curation entries we can view, filter them down to the current disease
        return self._authed_curation_set.filter(
            Q(extra_variants=obj.svip_variant.variant) | Q(variant=obj.svip_variant.variant),
            Q(disease=obj.disease)
        )

    @staticmethod
    def get_sample_count(obj):
        return obj.sample_set.count()

    def get_curation_entries(self, obj):
        return [
            CurationEntrySerializer(x, context={'request': self.context['request']}).data
            for x in self._curation_entries(obj)
        ]

    @staticmethod
    def get_sample_diseases_count(obj):
        return (
            obj.sample_set
                .values(name=F('disease_in_svip__disease__name'))
                .annotate(count=Count('disease_in_svip__disease__name'))
                .distinct().order_by('-count')
        )

    def get_pathogenic(self, obj):
        return pathogenic(self._curation_entries(obj))

    def get_clinical_significance(self, obj):
        return clinical_significance(self._curation_entries(obj))

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


# ================================================================================================================
# === Curation
# ================================================================================================================

class CurationEntrySerializer(serializers.ModelSerializer):
    variant = SimpleVariantSerializer()

    # extra_variants = serializers.PrimaryKeyRelatedField(
    #     allow_empty=False, many=True, queryset=Variant.objects.all(),
    #     style={'base_template': 'input.html'}
    # )
    extra_variants = SimpleVariantSerializer(many=True, style={'base_template': 'input.html'}, required=False)

    owner = serializers.PrimaryKeyRelatedField(default=serializers.CurrentUserDefault(), queryset=User.objects.all())
    status = serializers.ChoiceField(choices=tuple(CURATION_STATUS.items()))
    created_on = serializers.DateTimeField(read_only=True, default=now)

    disease = DiseaseSerializer()  # returns the full disease object instead of just its ID

    owner_name = serializers.SerializerMethodField()
    formatted_variants = serializers.SerializerMethodField()

    @staticmethod
    def get_owner_name(obj):
        return obj.owner_name()

    @staticmethod
    def get_formatted_variants(obj):
        return [format_variant(x) for x in obj.extra_variants.all().order_by('id')]

    @staticmethod
    def _remap_multifields(validated_data):
        # replace references to variant and disease IDs with the actual backing objects
        # note that we presume here that the variant and disease IDs they specify already exist
        validated_data['variant'] = Variant.objects.get(id=validated_data['variant']['id'])
        validated_data['disease'] = Disease.objects.get(id=validated_data['disease']['id'])
        validated_data['extra_variants'] = Variant.objects.filter(id__in=[x['id'] for x in validated_data['extra_variants']])

    def create(self, validated_data):
        self._remap_multifields(validated_data)
        validated_data["owner"] = self.fields["owner"].get_default()
        return super().create(validated_data)

    def update(self, instance, validated_data):
        validated_data.pop('owner')
        self._remap_multifields(validated_data)
        return super().update(instance, validated_data)

    # def save(self, **kwargs):
    #     # force owner to be the current user
    #     # FIXME: we should include a caveat for superusers
    #     # TODO: use stricter validation if the status isn't 'draft'
    #     kwargs["owner"] = self.fields["owner"].get_default()
    #     return super().save(**kwargs)

    def validate(self, data):
        if data['status'] != 'draft':
            # holds all errors that've been detected so far
            errors = {}

            # TODO: perform more stringent validation
            # FIXME: for now we'll do validation here, but ideally it should be factored out
            non_empty_fields = (
                'disease',
                'variant',
                'type_of_evidence',
                'effect',
                # 'tier_level_criteria', # only required if type_of_evidence != 'Excluded'
                'mutation_origin',
                'support',
            )

            empty_fields = [k for k in non_empty_fields if k not in data or data[k] in ('', None)]

            if len(empty_fields) > 0:
                errors.update(dict(
                    (k, "Field '%s' cannot be null or empty" % k) for k in empty_fields
                ))

            # also ensure that drug is specified if the type_of_evidence is "Predictive / Therapeutic"
            if data['type_of_evidence'] == "Predictive / Therapeutic" and field_is_empty(data, 'drugs', is_array=True):
                errors.update({
                    'drug': "Field 'drug' cannot be null or empty if type_of_evidence is 'Predictive / Therapeutic'"
                })

            if data['type_of_evidence'] != "Excluded" and field_is_empty(data, 'tier_level_criteria'):
                errors.update({
                    'type_of_evidence': "Field 'type_of_evidence' cannot be null or empty if type_of_evidence is not 'Excluded'"
                })

            if data['type_of_evidence'] == "Excluded" and field_is_empty(data, 'summary'):
                errors.update({
                    'summary': "Field 'summary' cannot be null or empty if type_of_evidence is 'Excluded'"
                })


            if len(errors) > 0:
                raise serializers.ValidationError(errors)

        return super().validate(data)

    class Meta:
        model = CurationEntry
        fields = (
            'id',
            'disease',
            'variant',
            'extra_variants',

            'type_of_evidence',
            'drugs',
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

        extra_kwargs = {
            # ensure that DRF knows the 'comment' and 'summary' fields aren't required.
            'comment': { 'required': False, 'allow_blank': True },
            'summary': { 'required': False, 'allow_blank': True }
        }


# ================================================================================================================
# === Samples
# ================================================================================================================

class SampleSerializer(serializers.ModelSerializer):
    disease_name = serializers.SerializerMethodField()

    @staticmethod
    def get_disease_name(obj):
        return obj.disease_in_svip.disease.name

    class Meta:
        model = Sample
        fields = '__all__'
