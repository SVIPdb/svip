# non-model-backed functional endpoints
from functools import reduce, total_ordering

from django.db.models.functions import Concat, Length
from django.db.models import Count, Q, F, Value, CharField, Case, When
from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from api.models import Phenotype, Variant, Gene, CurationEntry
from api.utils import format_variant
from references.prot_to_hgvs import three_to_one_icase

MAX_GENES = 100
MAX_VARIANTS = 100

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
                Q(description__icontains=search_term) 
                #|
                #(Q(gene__aliases__icontains=parts[0]) & Q(name__icontains=parts[1:])) |
                #(
                #    (Q(gene__symbol__icontains=parts[0]) | Q(gene__aliases__icontains=parts[0])) &
                #    (
                #        Q(*(('hgvs_c__icontains', x) for x in parts[1:]), _connector=Q.OR) |
                #        Q(*(('hgvs_p__icontains', x) for x in parts[1:]), _connector=Q.OR) |
                #        Q(*(('hgvs_g__icontains', x) for x in parts[1:]), _connector=Q.OR)
                #    )
                #)
            )

            # convert full amino acids to their single-letter abbreviations, since that's how they're stored in the
            # database; e.g., 'Val600Glu' becomes 'V600E'
            collapsed_search = reduce(lambda acc, v: v[0].sub(v[1], acc), three_to_one_icase.items(), search_term)

            queried_variants = Variant.objects.filter(
                q_set | Q(name__contains=collapsed_search)
            ).select_related('gene')

            #start variants by chrosome number, then by their genomic position
            vq = queried_variants.annotate(chr_digits=Length('chromosome')).annotate(sortable_chr=Case(
                #if chromosome is a 1-digit string, then we want variant to come first so add a '0' before (eg. 6 should come before 10)
                When(chr_digits=1, then=Concat(Value('0'), F('chromosome'), output_field=CharField())),
                default=F('chromosome')
            )).order_by('sortable_chr', 'start_pos')

            if in_svip:
                vq = vq.filter(variantinsvip__isnull=False)

            vq = vq.values('id', 'gene', 'hgvs_c', 'hgvs_p', 'hgvs_g', 'description', 'sources')

            final_vq = vq.distinct()[:MAX_VARIANTS]

            normalized_search = search_term.lower()
            v_resp = list(format_variant(x, normalized_search) for x in final_vq)

            if not variants_only:
                gq = Gene.objects.filter(Q(symbol__icontains=search_term) | Q(aliases__icontains=search_term))

                if in_svip:
                    gq = gq.annotate(svip_vars=Count('variant__variantinsvip')).filter(svip_vars__gt=0)

                gq = gq.values('id', 'symbol', 'aliases')

                g_resp = list({
                    'id': x['id'],
                    'type': 'g',
                    'label': (
                        "%s (aka: %s)" % (x['symbol'], ", ".join(x['aliases']))
                        if len(x['aliases']) > 0 else
                        x['symbol']
                    )
                } for x in gq.order_by('symbol')[:MAX_GENES])

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
            # 'phenotypes': Phenotype.objects.count(),
            'svip_curations': CurationEntry.objects.count()
        })
