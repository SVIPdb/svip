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
from django.urls import path, re_path, include

# jwt auth
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView, TokenVerifyView

# drf-yasg schema metadata
from drf_yasg.views import get_schema_view
from drf_yasg import openapi
from rest_framework import permissions, routers

from api import views

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

# django-rest-framework router paths
router = routers.DefaultRouter()
# router.register(r'users', views.UserViewSet)
# router.register(r'groups', views.GroupViewSet)
router.register(r'genes', views.GeneViewSet)
router.register(r'variants', views.VariantViewSet)
router.register(r'association', views.AssociationViewSet)
router.register(r'phenotype', views.PhenotypeViewSet)
router.register(r'evidence', views.EvidenceViewSet)
router.register(r'environmental_context', views.EnvironmentalContextViewSet)


urlpatterns = [
    path('admin/', admin.site.urls),

    # jwt auth paths
    re_path(r'^api/token/$', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    re_path(r'^api/token/refresh/$', TokenRefreshView.as_view(), name='token_refresh'),
    re_path(r'^api/token/verify/$', TokenVerifyView.as_view(), name='token_verify'),

    # drf routes
    re_path(r'^', include(router.urls)),
    re_path(r'^api-auth/', include('rest_framework.urls', namespace='rest_framework')),

    # drf-yasg routes
    re_path(r'^swagger(?P<format>\.json|\.yaml)$', schema_view.without_ui(cache_timeout=0), name='schema-json'),
    re_path(r'^swagger/$', schema_view.with_ui('swagger', cache_timeout=0), name='schema-swagger-ui'),
    re_path(r'^redoc/$', schema_view.with_ui('redoc', cache_timeout=0), name='schema-redoc'),
]
