from rest_framework import serializers

from api.models import HarvestRun


class HarvestRunSerializer(serializers.ModelSerializer):
    class Meta:
        model = HarvestRun
        fields = '__all__'
