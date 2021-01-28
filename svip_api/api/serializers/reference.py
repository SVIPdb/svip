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
            if not data:
                raise ValueError()

            # now we get an object from the frontend, which has at least 'name' in it
            if 'id' in data:
                return to_dict(Disease.objects.get(id=int(data['id'])))
            elif 'name' in data:
                # see if it belongs to an existing disease
                # if it doesn't, we'll just have to bail
                try:
                    candidate = Disease.objects.get(name=data['name'])
                    return to_dict(candidate)
                except Disease.DoesNotExist:
                    raise ValueError()

        except ValueError:
            return super().to_internal_value(data)

    class Meta:
        model = Disease
        fields = (
            'id',
            'localization',
            'abbreviation',
            'name',
            'topo_code',
            'morpho_code',
            'snomed_code',
            'snomed_name',
            'details',
            'user_created',
            'created_on',
        )
        read_only_fields = (
            'localization',
            'abbreviation',
            'name',
            'topo_code',
            'morpho_code',
            'snomed_code',
            'snomed_name',
            'details',
            'user_created',
            'created_on',
        )
