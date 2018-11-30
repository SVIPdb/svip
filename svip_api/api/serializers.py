from django.contrib.auth.models import User, Group
from rest_framework import serializers

from api.models import Gene, Variant, Association, Phenotype, Evidence, EnvironmentalContext


class UserSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = User
        fields = ('url', 'username', 'email', 'groups')


class GroupSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Group
        fields = ('url', 'name')


class GeneSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Gene
        fields = '__all__'


class VariantSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Variant
        fields = '__all__'


class AssociationSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Association
        # fields = '__all__'
        exclude = ('payload',)


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
