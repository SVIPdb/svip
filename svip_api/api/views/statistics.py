import itertools

from django.db.models import Count
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.reverse import reverse
from rest_framework.viewsets import ViewSet

from api.models import Gene, Source, VariantInSource, Phenotype, Variant, HarvestRun, CurationEntry
from api.serializers.harvesting import HarvestRunSerializer


class Statistics(ViewSet):
    def list(self, request):
        """
        Statistics provides exclusively aggregate statistics about the database.
        :param request:
        :return:
        """

        return Response({
            'basic': reverse('stats-basic', request=request),
            'full': reverse('stats-full', request=request),
            'harvests': reverse('stats-harvests', request=request)
        })

    @action(detail=False)
    def basic(self, request):
        return Response({
            'genes': Gene.objects.count(),
            'svip_genes': Gene.objects.filter(variant__variantinsvip__isnull=False).distinct().count(),
            'variants': Variant.objects.count(),
            'svip_variants': Variant.objects.filter(variantinsvip__isnull=False).distinct().count(),
            # 'phenotypes': Phenotype.objects.count(),
            'svip_curations': CurationEntry.objects.count()
        })

    @action(detail=False)
    def full(self, request):
        """
        Produces a
        :param request:
        :return:
        """
        genes_by_source = (
            VariantInSource.objects
                .values('variant__gene__symbol', 'variant__gene__id', 'source__name')
                .annotate(Count('variant__gene'))
                .order_by('variant__gene__symbol', 'source__name')
        )
        grouped_genes = itertools.groupby(genes_by_source, lambda k: (k['variant__gene__symbol'], k['variant__gene__id']))

        return Response({
            'genes': {
                'total_genes': Gene.objects.count(),
                'sources': Source.objects.values('name', 'display_name'),
                'variants_by_source': dict(
                    (
                        k[0],
                        {
                            'gene_id': k[1],
                            'sources': dict((x['source__name'], x['variant__gene__count']) for x in g)
                        }
                    ) for k, g in grouped_genes
                )
            }
        })

    @action(detail=False)
    def harvests(self, request):
        harvests = HarvestRun.objects.all().order_by('-id')
        
        return Response({
            'harvests': HarvestRunSerializer(harvests, many=True).data
        })
