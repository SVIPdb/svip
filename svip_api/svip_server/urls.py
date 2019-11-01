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
from rest_framework_simplejwt.views import (
    TokenRefreshView, TokenVerifyView
)

# drf-yasg schema metadata
from drf_yasg.views import get_schema_view
from drf_yasg import openapi
from rest_framework import permissions

import api.views.beacon as beacon101
import api.views.beacon_v110 as beacon110
from api.views.proxies import socibp_proxy
from api.views.proxies.swisspo_proxy import get_pdbs, get_residues, get_pdb_data
from api.views.proxies.variomes_proxy import variomes_single_ref, variomes_search
from svip_server import settings

from svip_server.tokens import GroupsTokenObtainPairView, TokenInfo, TokenInvalidate


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
    # used for clients to retrieve non-sensitive token info if using httponly cookies
    re_path(r'^api/token/info/$', TokenInfo.as_view(), name='token_info'),
    re_path(r'^api/token/invalidate/$', TokenInvalidate.as_view(), name='token_invalidate'),

    # drf routes
    path('api/v1/', include('api.urls')),
    re_path(r'^api/api-auth/', include('rest_framework.urls', namespace='rest_framework')),

    # drf-yasg routes
    re_path(r'^api/v1/swagger(?P<format>\.json|\.yaml)$', schema_view.without_ui(cache_timeout=0), name='schema-json'),
    re_path(r'^api/v1/swagger/$', schema_view.with_ui('swagger', cache_timeout=0), name='schema-swagger-ui'),
    re_path(r'^api/v1/redoc/$', schema_view.with_ui('redoc', cache_timeout=0), name='schema-redoc'),

    # beacon v1.0.1 route
    re_path(r'^api/v1/beacon/$', beacon101.beacon, name='beacon101'),
    re_path(r'^api/v1/beacon/query/$', beacon101.beacon_query, name='beacon101_query'),

    # beacon v1.1.0 route
    re_path(r'^api/v1/beacon/v1.1.0/$', beacon110.beacon, name='beacon110'),
    re_path(r'^api/v1/beacon/v1.1.0/query/$', beacon110.beacon_query, name='beacon110_query'),
    re_path(r'^api/v1/beacon/v1.1.0/filtering_terms/$', beacon110.filtering_terms, name='beacon110_filtering_terms'),

    # proxied routes from external APIs
    re_path(r'^api/v1/variomes_single_ref', variomes_single_ref, name='variomes_single_ref'),
    re_path(r'^api/v1/variomes_search', variomes_search, name='variomes_search'),

    # swiss-po specific routes
    re_path(r'^api/v1/swiss_po/get_pdbs/(?P<protein>.+)$', get_pdbs, name='swisspo_get_pdbs'),
    re_path(r'^api/v1/swiss_po/get_residues/(?P<pdb_id>[^:]+):(?P<chain>[A-Z])$', get_residues, name='swisspo_get_residues'),
    re_path(r'^api/v1/swiss_po/get_pdb_data/(?P<pdb_path>.+)$', get_pdb_data, name='swisspo_get_pdb_data'),

    # socibp proxying routes
    re_path(r'^api/v1/socibp/genes', socibp_proxy.get_genes, name='socibp_get_genes'),
    re_path(r'^api/v1/socibp/stats/(?P<gene>.+)/(?P<change>.+)$', socibp_proxy.get_changed_samples, name='socibp_stats'),
]

# serve static files from the dev server
# (in deployments, this is handled by a proxy frontend, e.g. nginx)
urlpatterns += staticfiles_urlpatterns()

# enables the django debug toolbar
if settings.DEBUG:
    import debug_toolbar
    urlpatterns = [
        path('__debug__/', include(debug_toolbar.urls)),

    ] + urlpatterns
