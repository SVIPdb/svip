import jwt

from rest_framework.permissions import IsAuthenticated
from rest_framework import generics, status, serializers
from rest_framework.response import Response
from rest_framework_simplejwt.authentication import JWTTokenUserAuthentication

from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.views import TokenObtainPairView

from rest_framework_simplejwt.serializers import TokenObtainSlidingSerializer
from rest_framework_simplejwt.views import TokenObtainSlidingView
from rest_framework_simplejwt.settings import api_settings

# for regular, non-sliding tokens

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


# for the sliding tokens

class GroupsTokenObtainSlidingSerializer(TokenObtainSlidingSerializer):
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


class GroupsTokenObtainSlidingView(TokenObtainSlidingView):
    serializer_class = GroupsTokenObtainSlidingSerializer


class TokenInfo(generics.GenericAPIView):
    """
    Retrieves information about our token (say, if we're using httponly cookies and can't read it directly).
    """
    permission_classes = (IsAuthenticated,)
    authentication_classes = (JWTTokenUserAuthentication,)
    serializer_class = None

    def get(self, request, *args, **kwargs):
        return Response(request.auth.payload, status=status.HTTP_200_OK)


class TokenInvalidate(generics.GenericAPIView):
    permission_classes = ()
    authentication_classes = (JWTTokenUserAuthentication,)
    serializer_class = None

    def post(self, request, *args, **kwargs):
        # FIXME: implement blacklisting the token when we log out, too

        response = Response(status=status.HTTP_200_OK)
        results = []

        # definitely clear their sessionid cookie when they make this request, too
        response.delete_cookie('sessionid')
        results.append('cleared sessionid')

        # attempt to clear the JWT_AUTH_COOKIE if it exists
        if hasattr(api_settings, 'JWT_AUTH_COOKIE') and api_settings.JWT_AUTH_COOKIE:
            response.delete_cookie(api_settings.JWT_AUTH_COOKIE)
            results.append('cleared ' + api_settings.JWT_AUTH_COOKIE)

        response.data = {'results': results}
        return response
