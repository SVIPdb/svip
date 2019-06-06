# non-model-backed functional endpoints
from functools import reduce

from django.db.models import Count, Q
from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from api.models import Phenotype, Variant, Gene
from references.prot_to_hgvs import three_to_one_icase


class QueryView(viewsets.ViewSet):
    def list(self, request, format=None):
        """
        Gets a list of genes and variants for which the query term, 'q', occurs in its description.
        :param request:
        :return: a list of variant objects, consisting of just the id and description (called 'label') for brevity
        """
        resp = []
        search_term = request.GET.get('q', None)
        in_svip = (request.GET.get('in_svip', False) == 'true')

        if search_term is not None and search_term != '':
            # convert full amino acids to their single-letter abbreviations, since that's how they're stored in the
            # database; e.g., 'Val600Glu' becomes 'V600E'
            collapsed_search = reduce(lambda acc, v: v[0].sub(v[1], acc), three_to_one_icase.items(), search_term)

            gq = Gene.objects.filter(
                Q(symbol__icontains=search_term) | Q(aliases__icontains=search_term)
            )
            vq = Variant.objects.filter(
                Q(description__icontains=search_term) | Q(hgvs_c__icontains=search_term) |
                Q(name__contains=collapsed_search)
            )

            if in_svip:
                gq = gq.annotate(svip_vars=Count('variant__variantinsvip')).filter(svip_vars__gt=0)
                vq = vq.filter(variantinsvip__isnull=False)

            g_resp = list({
                'id': x.id,
                'type': 'g',
                'label': "%s (aka: %s)" % (x.symbol, ", ".join(x.aliases))
            } for x in gq)
            v_resp = list({
                'id': x.id,
                'g_id': x.gene.id,
                'type': 'v',
                'label': "%s (%s)" % (
                    x.description, x.hgvs_c.split(':')[1]) if x.hgvs_c else x.description,
                'sources': sorted(x.sources)
            } for x in vq)

            resp = g_resp + v_resp
        else:
            # send back the full list of genes
            gq = Gene.objects.all()

            if in_svip:
                gq = gq.annotate(svip_vars=Count('variant__variantinsvip')).filter(svip_vars__gt=0)

            g_resp = list({
                'id': x.id,
                'type': 'g',
                'label': x.symbol
            } for x in gq)
            resp = g_resp

        return Response(resp)

    @action(detail=False)
    def stats(self, request):
        return Response({
            'genes': Gene.objects.count(),
            'svip_genes': Gene.objects.filter(variant__variantinsvip__isnull=False).distinct().count(),
            'variants': Variant.objects.count(),
            'svip_variants': Variant.objects.filter(variantinsvip__isnull=False).distinct().count(),
            'phenotypes': Phenotype.objects.count()
        })
