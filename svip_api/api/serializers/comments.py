from rest_framework import serializers
from django.contrib.auth import get_user_model

from api.models.comments import VariantComment

User = get_user_model()


class VariantCommentSerializer(serializers.ModelSerializer):
    owner = serializers.PrimaryKeyRelatedField(default=serializers.CurrentUserDefault(), read_only=True)
    created_on = serializers.DateTimeField(read_only=True)
    owner_name = serializers.SerializerMethodField()

    @staticmethod
    def get_owner_name(obj):
        return obj.owner_name()

    def create(self, validated_data):
        validated_data["owner"] = self.fields["owner"].get_default()
        return super().create(validated_data)

    class Meta:
        model = VariantComment
        fields = '__all__'
