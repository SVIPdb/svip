# non-model-backed functional endpoints
from functools import reduce

from django.db.models import Count, Q
from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from api.models import Phenotype, Variant, Gene
from api.utils import format_variant
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
        variants_only = (request.GET.get('variants_only', False) == 'true')

        if search_term is not None and search_term != '':
            # FIXME: tokenize search_term into space-delimited tokens and perform field matching on each token
            parts = search_term.split(" ")
            q_set = Q(
                # Q(*(('description__icontains', x) for x in parts), _connector=Q.AND) |
                Q(description__icontains=search_term) |
                (Q(gene__aliases__icontains=parts[0]) & Q(name__icontains=parts[1:])) |
                (
                    (Q(gene__symbol__icontains=parts[0]) | Q(gene__aliases__icontains=parts[0])) &
                    (
                        Q(*(('hgvs_c__icontains', x) for x in parts[1:]), _connector=Q.OR) |
                        Q(*(('hgvs_p__icontains', x) for x in parts[1:]), _connector=Q.OR) |
                        Q(*(('hgvs_g__icontains', x) for x in parts[1:]), _connector=Q.OR)
                    )
                )
            )

            # convert full amino acids to their single-letter abbreviations, since that's how they're stored in the
            # database; e.g., 'Val600Glu' becomes 'V600E'
            collapsed_search = reduce(lambda acc, v: v[0].sub(v[1], acc), three_to_one_icase.items(), search_term)

            vq = Variant.objects.filter(
                q_set | Q(name__contains=collapsed_search)
            ).select_related('gene')

            if in_svip:
                vq = vq.filter(variantinsvip__isnull=False)

            normalized_search = search_term.lower()
            v_resp = list(format_variant(x, normalized_search) for x in vq.distinct())

            if not variants_only:
                gq = Gene.objects.filter(Q(symbol__icontains=search_term) | Q(aliases__icontains=search_term))

                if in_svip:
                    gq = gq.annotate(svip_vars=Count('variant__variantinsvip')).filter(svip_vars__gt=0)

                g_resp = list({
                    'id': x.id,
                    'type': 'g',
                    'label': "%s (aka: %s)" % (x.symbol, ", ".join(x.aliases))
                } for x in gq.order_by('symbol'))

                resp = g_resp + v_resp
            else:
                resp = v_resp

        elif not variants_only:
            # send back the full list of genes
            gq = Gene.objects.all()

            if in_svip:
                gq = gq.annotate(svip_vars=Count('variant__variantinsvip')).filter(svip_vars__gt=0)

            g_resp = list({
                'id': x.id,
                'type': 'g',
                'label': x.symbol
            } for x in gq.order_by('symbol'))
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
