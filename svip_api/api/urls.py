from django.urls import path, include
from rest_framework import routers
from rest_framework_nested import routers as nested_routers

from api import views


class OptionalSlashRouter(routers.DefaultRouter):
    def __init__(self, *args, **kwargs):
        super(OptionalSlashRouter, self).__init__(*args, **kwargs)
        self.trailing_slash = '/?'


router = OptionalSlashRouter()

# REFERENCE: regarding the use of the 'basename' attribute on routes, from the docs:
# "basename - The base to use for the URL names that are created. If unset the basename will be automatically generated
# based on the queryset attribute of the viewset, if it has one. Note that if the viewset does not include a queryset
# attribute then you must set basename when registering the viewset."
# - https://www.django-rest-framework.org/api-guide/routers/#usage

# ------------------------------------------
# - auth object endpoints (currently disabled)
# ------------------------------------------
# router.register(r'users', views.UserViewSet)
# router.register(r'groups', views.GroupViewSet)


# ------------------------------------------
# - general endpoints
# ------------------------------------------

router.register(r'genes', views.GeneViewSet)
router.register(r'sources', views.SourceViewSet)
router.register(r'variants', views.VariantViewSet, basename='variant')

# nested route: genes/:id/variants
genes_router = nested_routers.NestedSimpleRouter(
    router, r'genes', lookup='gene')
genes_router.register(r'variants', views.VariantViewSet,
                      basename='gene-variants')

variants_router = nested_routers.NestedSimpleRouter(
    router, r'variants', lookup='variant')
variants_router.register(
    r'sources', views.VariantInSourceViewSet, basename='sources')
variants_router.register(
    r'comments', views.VariantCommentViewSet, basename='comments')

# special endpoint for aggregate and search actions
router.register(r'query', views.QueryView, basename="query")

# special endpoint for statistics
router.register(r'stats', views.Statistics, basename="stats")

# ------------------------------------------
# - public database endpoints
# ------------------------------------------

# entrypoint into public db data
router.register(r'variants_in_sources',
                views.VariantInSourceViewSet, basename='variantinsource')

router.register(r'associations', views.AssociationViewSet,
                basename='association')
router.register(r'collapsed_associations',
                views.CollapsedAssociationViewSet, basename='collapsedassociation')
router.register(r'phenotypes', views.PhenotypeViewSet)
router.register(r'evidence_items', views.EvidenceViewSet)
router.register(r'environmental_contexts', views.EnvironmentalContextViewSet)

variants_in_sources_router = nested_routers.NestedSimpleRouter(router, r'variants_in_sources',
                                                               lookup='variant_in_source')
# creates variants_in_sources/x/associations
variants_in_sources_router.register(
    r'associations', views.AssociationViewSet, basename='associations')
variants_in_sources_router.register(r'collapsed_associations', views.CollapsedAssociationViewSet,
                                    basename='collapsedassociations')

# ------------------------------------------
# - reference data endpoints
# ------------------------------------------

router.register(r'drugs', views.DrugViewSet)
router.register(r'diseases', views.DiseaseViewSet)

# ICD-O models, for curation
router.register(r'icdo_morpho', views.IcdOMorphoViewSet)
router.register(r'icdo_topo', views.IcdOTopoViewSet)

# ------------------------------------------
# - SVIP-specific endpoints, top-level and nested
# ------------------------------------------

# entrypoint into SVIP-specific data
router.register(r'variants_in_svip', views.VariantInSVIPViewSet,
                basename='variantinsvip')

variants_in_svip_router = nested_routers.NestedSimpleRouter(
    router, r'variants_in_svip', lookup='variant_in_svip')
variants_in_svip_router.register(
    r'diseases', views.DiseaseInSVIPViewSet, basename='disease')

# note: the 'lookup' field determines the prefix for the public key that's passed to SampleViewSet
# e.g., in this case it receives the following keys: {'variant_in_svip_pk': '296', 'disease_pk': '131'}
diseases_router = nested_routers.NestedSimpleRouter(
    variants_in_svip_router, r'diseases', lookup='disease')
diseases_router.register(r'samples', views.SampleViewSet, basename='sample')

router.register(r'curation_requests',
                views.CurationRequestViewSet, basename='curation_requests')
router.register(r'curation_entries', views.CurationEntryViewSet,
                basename='curation_entries')

router.register(r'comments', views.VariantCommentViewSet,
                basename='variant_comments')

# variants submitted for processing in SVIP
router.register(r'submitted_variants',
                views.SubmittedVariantViewSet, basename='submitted_variants')
router.register(r'submitted_variant_batches',
                views.SubmittedVariantBatchViewSet, basename='submitted_variant_batches')

router.register(r'reviews', views.CurationReviewViewSet, basename='reviews')
router.register(r'summary_comments', views.SummaryCommentViewSet,
                basename='summary_comments')
router.register(r'sib_annotations_1', views.SIBAnnotation1ViewSet,
                basename='sib_annotations_1')
router.register(r'sib_annotations_2', views.SIBAnnotation2ViewSet,
                basename='sib_annotations_2')

urlpatterns = [
    path('review_data', views.svip.ReviewDataView.as_view(), name='review_data'),
    path('', include(router.urls)),
    path('', include(genes_router.urls)),
    path('', include(variants_router.urls)),
    path('', include(variants_in_sources_router.urls)),
    path('', include(variants_in_svip_router.urls)),
    path('', include(diseases_router.urls)),
]
