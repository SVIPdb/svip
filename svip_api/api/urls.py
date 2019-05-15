from django.urls import path, re_path, include

# drf-yasg schema metadata
from rest_framework import routers
from rest_framework_nested import routers as nested_routers

from api import views


class OptionalSlashRouter(routers.DefaultRouter):
    def __init__(self, *args, **kwargs):
        super(OptionalSlashRouter, self).__init__(*args, **kwargs)
        self.trailing_slash = '/?'


# django-rest-framework router paths
router = OptionalSlashRouter()

# router.register(r'users', views.UserViewSet)
# router.register(r'groups', views.GroupViewSet)
router.register(r'genes', views.GeneViewSet)
router.register(r'sources', views.SourceViewSet)
router.register(r'variants', views.VariantViewSet, basename='variant')
router.register(r'variants_in_sources', views.VariantInSourceViewSet, basename='variantinsource')
router.register(r'variants_in_svip', views.VariantInSVIPViewSet, basename='variantinsvip')
# router.register(r'svip_samples', views.SampleViewSet, basename='variantinsvip')
router.register(r'associations', views.AssociationViewSet, basename='association')
router.register(r'phenotypes', views.PhenotypeViewSet)
router.register(r'evidence_items', views.EvidenceViewSet)
router.register(r'environmental_contexts', views.EnvironmentalContextViewSet)

router.register(r'query', views.QueryView, basename="query")

# add in the nested routers as well
genes_router = nested_routers.NestedSimpleRouter(router, r'genes', lookup='gene')
genes_router.register(r'variants', views.VariantViewSet, base_name='gene-variants')

variants_router = nested_routers.NestedSimpleRouter(router, r'variants', lookup='variant')
variants_router.register(r'sources', views.VariantInSourceViewSet, base_name='sources')

variants_in_sources_router = nested_routers.NestedSimpleRouter(router, r'variants_in_sources', lookup='variant_in_source')
variants_in_sources_router.register(r'associations', views.AssociationViewSet, base_name='variant_in_source-associations')

variants_in_svip_router = nested_routers.NestedSimpleRouter(router, r'variants_in_svip', lookup='variant_in_svip')
variants_in_svip_router.register(r'samples', views.SampleViewSet, base_name='variant_in_svip-samples')


# FIXME: the below declaration is currently unused
# app_name = 'api'
# urlpatterns = [
#     re_path(r'^/api/v1/', include(router.urls)),
#     re_path(r'^/api/v1/', include(genes_router.urls)),
#     re_path(r'^/api/v1/', include(variants_router.urls)),
# ]
