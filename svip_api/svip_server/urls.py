"""svip_server URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/2.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.contrib.staticfiles.urls import staticfiles_urlpatterns
from django.urls import path, re_path, include

# jwt auth
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView, TokenVerifyView

# drf-yasg schema metadata
from drf_yasg.views import get_schema_view
from drf_yasg import openapi
from rest_framework import permissions

import api.urls as api_router
from svip_server.tokens import GroupsTokenObtainPairView

schema_view = get_schema_view(
    openapi.Info(
        title="SVIP API",
        default_version='v1',
        description="Early version of the SVIP API - https://svip.ch",
        # terms_of_service="https://www.google.com/policies/terms/",
        contact=openapi.Contact(email="alquaddoomi@nexus.ethz.ch"),
        license=openapi.License(name="BSD License"),
    ),
    # validators=['flex', 'ssv'],
    validators=['ssv'],
    public=True,
    permission_classes=(permissions.AllowAny,)
)


urlpatterns = [
    path('api/admin/', admin.site.urls),

    # jwt auth paths
    re_path(r'^api/token/$', GroupsTokenObtainPairView.as_view(), name='token_obtain_pair'),
    re_path(r'^api/token/refresh/$', TokenRefreshView.as_view(), name='token_refresh'),
    re_path(r'^api/token/verify/$', TokenVerifyView.as_view(), name='token_verify'),

    # drf routes
    re_path(r'^api/v1/', include(api_router.router.urls)),
    re_path(r'^api/v1/', include(api_router.genes_router.urls)),
    re_path(r'^api/v1/', include(api_router.variants_router.urls)),
    re_path(r'^api/v1/', include(api_router.variants_in_sources_router.urls)),

    # re_path(r'^api/v1/', include(api.urls)),

    re_path(r'^api/api-auth/', include('rest_framework.urls', namespace='rest_framework')),

    # drf-yasg routes
    re_path(r'^api/v1/swagger(?P<format>\.json|\.yaml)$', schema_view.without_ui(cache_timeout=0), name='schema-json'),
    re_path(r'^api/v1/swagger/$', schema_view.with_ui('swagger', cache_timeout=0), name='schema-swagger-ui'),
    re_path(r'^api/v1/redoc/$', schema_view.with_ui('redoc', cache_timeout=0), name='schema-redoc'),
]

# serve static files from the dev server
# (in deployments, this is handled by a proxy frontend, e.g. nginx)
urlpatterns += staticfiles_urlpatterns()
