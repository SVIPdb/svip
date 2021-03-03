from rest_framework import serializers

from api.models import IcdOTopo, IcdOMorpho



class IcdOMorphoSerializer(serializers.ModelSerializer):
    id = serializers.IntegerField(required=False)

    class Meta:
        model = IcdOMorpho
        fields = (
            'id',
            'cell_type_code',
            'icd_o_morpho_behavior',
            'icd_o_morpho_level',
            'term',
            'code_reference',
            'obs',
            'additional_information',
            'created_on',
            'user_created',
            'morpho_version',
        )
        read_only_fields = (
            'cell_type_code',
            'icd_o_morpho_behavior',
            'icd_o_morpho_level',
            'term',
            'code_reference',
            'obs',
            'additional_information',
            'created_on',
            'user_created',
            'morpho_version',
        )

class IcdOTopoSerializer(serializers.ModelSerializer):
    id = serializers.IntegerField(required=False)

    class Meta:
        model = IcdOTopo
        fields = (
            'id',
            'topo_code',
            'topo_level',
            'topo_term',
            'topo_version',
        )
        read_only_fields = (
            'topo_code',
            'topo_level',
            'topo_term',
            'topo_version',
        )
