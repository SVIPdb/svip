from rest_framework import serializers

from api.models import Drug, Disease


class DrugSerializer(serializers.ModelSerializer):
    class Meta:
        model = Drug
        fields = '__all__'


class DiseaseSerializer(serializers.ModelSerializer):
    def to_internal_value(self, data):
        from api.utils import to_dict
        try:
            return to_dict(Disease.objects.get(id=int(data)))
        except ValueError:
            return super().to_internal_value(data)

    class Meta:
        model = Disease
        fields = '__all__'
