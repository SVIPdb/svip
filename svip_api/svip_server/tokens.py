from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework_simplejwt.views import TokenObtainPairView


class GroupsTokenObtainPairSerializer(TokenObtainPairSerializer):
    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)

        token['username'] = user.username
        token['groups'] = [x.name for x in user.groups.all()]

        # since the front-end expects all permissions to be communicated via the groups collection,
        # we add a virtual group here, 'active', that just indicates if the account is active
        if user.is_active:
            token['groups'].append('active')

        return token


class GroupsTokenObtainPairView(TokenObtainPairView):
    serializer_class = GroupsTokenObtainPairSerializer
