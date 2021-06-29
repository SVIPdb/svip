"""
Serializers for SVIP-specific models.
"""
import datetime

from django.contrib.admin.utils import NestedObjects
from django.contrib.auth import get_user_model
from django.db import transaction
from django.db.models import Count, Q, F
from django.utils.functional import cached_property
from django.utils.timezone import now
from rest_framework import serializers
from rest_framework_nested.serializers import NestedHyperlinkedModelSerializer

from api.models import VariantInSVIP, Sample, CurationEntry, Variant, Drug, IcdOMorpho, IcdOTopo, IcdOTopoApiDisease
from api.models.svip import Disease, DiseaseInSVIP, CURATION_STATUS, SummaryComment, CurationReview
from api.serializers import SimpleVariantSerializer
from api.serializers.icdo import IcdOMorphoSerializer, IcdOTopoSerializer
from api.serializers.reference import DiseaseSerializer
from api.shared import pathogenic, clinical_significance
from api.utils import format_variant, field_is_empty, model_field_null

User = get_user_model()


# ================================================================================================================
# === Disease Aggregation
# ================================================================================================================

class DiseaseInSVIPSerializer(NestedHyperlinkedModelSerializer):
    def __init__(self, *args, **kwargs):
        self._curation_cache = {}
        super().__init__(*args, **kwargs)

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
        return {
            "male": sum(1 for x in obj.sample_set.all() if x.gender == 'male'),
            "female": sum(1 for x in obj.sample_set.all() if x.gender == 'female')
        }

    @staticmethod
    def get_age_distribution(obj):
        # produce the age brackets merged with the number of age entries that match each bracket
        curYear = datetime.datetime.now().year
        ages = [curYear - int(x.year_of_birth) for x in obj.sample_set.all()]

        return dict(
            (bracket, sum(1 for x in ages if bracket_pred(x)))
                for bracket, bracket_pred in DiseaseInSVIPSerializer.age_brackets.items()
        )

    def get_samples(self, obj):
        user = self.context['request'].user
        if not user.has_perm('api.view_sample'):
            return []

        return SampleSerializer(obj.sample_set, many=True, read_only=True).data

    @cached_property
    def _authed_curation_set(self):
        return (
            CurationEntry.objects
                .authed_curation_set(self.context['request'].user)
        )

    def _curation_entries(self, obj):
        # authed_set = CurationEntry.objects.all()

        # attempt to get icd_o_morpho from the entry, or null if the entry has no disease
        obj_disease_morpho = obj.disease.icd_o_morpho if not model_field_null(obj, 'disease') else None

        # in addition to getting curation entries we can view, filter them down to the current disease
        if str(obj) not in self._curation_cache:
            self._curation_cache[str(obj)] = list(self._authed_curation_set.filter(
                Q(extra_variants=obj.svip_variant.variant) | Q(variant=obj.svip_variant.variant),
                Q(disease__icd_o_morpho__isnull=False, disease__icd_o_morpho=obj_disease_morpho)
            ).select_related('disease', 'variant', 'variant__gene').prefetch_related('extra_variants').all())

        return self._curation_cache[str(obj)]

    @staticmethod
    def get_sample_count(obj):
        return obj.sample_set.count()

    def get_curation_entries(self, obj):
        return CurationEntrySerializer(
            self._curation_entries(obj), many=True, context={'request': self.context['request']}
        ).data

    @staticmethod
    def get_sample_diseases_count(obj):
        return (
            obj.sample_set
                .values(name=F('disease_in_svip__disease__icd_o_morpho__term'))
                .annotate(count=Count('disease_in_svip__disease__icd_o_morpho__term'))
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
# === Variant Aggregation
# ================================================================================================================

class VariantInSVIPSerializer(serializers.HyperlinkedModelSerializer):
    diseases = DiseaseInSVIPSerializer(many=True, read_only=True, source='diseaseinsvip_set')

    class Meta:
        model = VariantInSVIP
        fields = (
            'url',
            'id',
            'variant',
            'summary',
            'tissue_counts',
            'diseases',
            'review_data',
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

    # disease is effectively a passthrough to icd_o_morpho + icd_o_topo, but it's still nice to see it
    disease = DiseaseSerializer(required=False, allow_null=True, read_only=True)

    icdo_morpho = IcdOMorphoSerializer(required=False, allow_null=True)
    icdo_topo = IcdOTopoSerializer(required=False, allow_null=True, many=True)

    owner_name = serializers.SerializerMethodField()
    formatted_variants = serializers.SerializerMethodField()

    @staticmethod
    def get_owner_name(obj):
        return obj.owner_name()

    @staticmethod
    def get_formatted_variants(obj):
        return [
            format_variant(x, isnt_dict=True) for x in obj.extra_variants.all()
        ]

    @staticmethod
    def _remap_multifields(validated_data):
        # replace references to variant and disease IDs with the actual backing objects
        # note that we presume here that the variant and disease IDs they specify already exist
        validated_data['variant'] = Variant.objects.get(id=validated_data['variant']['id'])
        validated_data['extra_variants'] = Variant.objects.filter(id__in=[x['id'] for x in validated_data['extra_variants']])

    @staticmethod
    def _assign_disease_by_morpho_topo(instance, icdo_morpho, icdo_topo_list):
        # approach: now that Disease is mutable, we can't simply point
        # multiple curation entries at the same Disease; instead, we need
        # to either look up a Disease that matches the morpho code + topo set
        # in this entry, or create it if it doesn't exist.

        # note that this produces a trail of Diseases that are *potentially*
        # no longer in use if we ever change the morpho code or topo codes.
        # we can either clean up these unused entries after updating, or
        # 'vacuum' them on a schedule with a script. this will require
        # identifying every model that refers to a Disease

        with transaction.atomic():
            if not icdo_morpho:
                # we can't assign a disease if they didn't specify a morpho field
                instance.disease = None
                instance.save()
                return None

            if instance.disease:
                # if there was previously a disease, check if it's in use and delete it if not
                collector = NestedObjects(using='default')  # or specific database
                collector.collect([instance.disease])

                if collector.can_fast_delete():
                    print("Fast-deleting old disease")
                    instance.disease.delete()
                else:
                    print("Can't fast-delete old disease: %s" % collector.nested())

            # build a Q-object that's all the topo entries related to the target Disease ANDed together
            q_objects = Q(icd_o_morpho=icdo_morpho['id'])

            if icdo_topo_list:
                for x in icdo_topo_list:
                    q_objects &= Q(icdotopoapidisease__icd_o_topo__id=x['id'])
            else:
                # we need to search for a morpho that has no associated topo codes
                q_objects &= Q(icdotopoapidisease=None)

            # either retrieve an existing disease that matches the description, or create it
            candidate = Disease.objects.filter(q_objects).first()

            if not candidate:
                candidate = Disease.objects.create(icd_o_morpho=IcdOMorpho.objects.get(id=icdo_morpho['id']))
                IcdOTopoApiDisease.objects.bulk_create([
                    IcdOTopoApiDisease(api_disease=candidate, icd_o_topo=IcdOTopo.objects.get(id=x['id']))
                    for x in (icdo_topo_list if icdo_topo_list else [])
                ])
                candidate.save()

            instance.disease = candidate
            instance.save()

    @staticmethod
    def ensure_drugs_exist(validated_data):
        if 'drugs' not in validated_data:
            return

        for drug in validated_data['drugs']:
            if not Drug.objects.filter(common_name=drug).first():
                Drug.objects.create(common_name=drug, user_created=True)


    def create(self, validated_data):
        icdo_morpho, icdo_topo_list = validated_data.pop('icdo_morpho'), validated_data.pop('icdo_topo')
        self._remap_multifields(validated_data)
        self.ensure_drugs_exist(validated_data)
        validated_data["owner"] = self.fields["owner"].get_default()
        result = super().create(validated_data)

        # after the instance is created, identify the disease and populate it
        self._assign_disease_by_morpho_topo(result, icdo_morpho, icdo_topo_list)
        return result

    def update(self, instance, validated_data):
        icdo_morpho, icdo_topo_list = validated_data.pop('icdo_morpho'), validated_data.pop('icdo_topo')
        validated_data.pop('owner')
        self._remap_multifields(validated_data)
        self.ensure_drugs_exist(validated_data)
        result = super().update(instance, validated_data)

        # after the instance is created, identify the disease and populate it
        self._assign_disease_by_morpho_topo(result, icdo_morpho, icdo_topo_list)
        return result

    def validate(self, data):
        if data['status'] != 'draft':
            # holds all errors that've been detected so far
            errors = {}

            # TODO: perform more stringent validation
            # FIXME: for now we'll do validation here, but ideally it should be factored out
            non_empty_fields = (
                # 'disease',
                'variant',
                'type_of_evidence',
                # 'effect',
                # 'tier_level_criteria', # only required if type_of_evidence != 'Excluded'
                # 'mutation_origin', # no longer requireds
                # 'support',
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

            # when the type of evidence is 'Excluded', most fields become optional, but 'summary' and 'comment'
            # become required. the following lists specify which fields must be filled in if it's not excluded
            # and which must be filled in if it *is* excluded.

            empty_fields_if_excluded = (
                'tier_level_criteria',
                'effect',
                'support'
            )
            non_empty_fields_if_excluded = (
                'summary',
                'comment'
            )

            if data['type_of_evidence'] != "Excluded":
                for field_name in empty_fields_if_excluded:
                    if field_is_empty(data, field_name):
                        errors.update({
                            'type_of_evidence': "Field '%s' cannot be null or empty if type_of_evidence is not 'Excluded'" % field_name
                        })

            elif data['type_of_evidence'] == "Excluded":
                for field_name in non_empty_fields_if_excluded:
                    if field_is_empty(data, field_name):
                        errors.update({
                            'summary': "Field '%s' cannot be null or empty if type_of_evidence is 'Excluded'" % field_name
                        })

            if len(errors) > 0:
                raise serializers.ValidationError(errors)

        return super().validate(data)

    class Meta:
        model = CurationEntry
        fields = (
            'id',
            'disease',
            'icdo_morpho',
            'icdo_topo',
            'variant',
            'extra_variants',

            'type_of_evidence',
            'drugs',
            'interactions',
            'effect',
            'tier_level_criteria',
            'tier_level',
            'mutation_origin',
            'associated_mendelian_diseases',
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
            
            'curation_evidence',
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
        return obj.disease_in_svip.disease.icd_o_morpho.term

    class Meta:
        model = Sample
        fields = '__all__'


# ================================================================================================================
# === SummaryComment
# ================================================================================================================

class SummaryCommentSerializer(serializers.ModelSerializer):
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    #kwargs = {
    #    'variant': 'variant',
    #}
    
    class Meta:
        model = SummaryComment
        fields = ('id', 'owner', 'content', 'variant', 'reviewer')
        extra_kwargs = {
            "content": {
                "required": False,
                "allow_null": True,
            },
            "reviewer": {
                "required": False,
                "allow_null": False,
            }
        }



class CurationReviewSerializer(serializers.ModelSerializer):
    
    def __init__(self, *args, **kwargs):
        many = kwargs.pop('many', True)
        super(CurationReviewSerializer, self).__init__(many=many, *args, **kwargs)
        
    class Meta:
        model = CurationReview
        fields = '__all__'
