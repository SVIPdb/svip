import json
import re
from collections import defaultdict
from itertools import groupby
from operator import itemgetter

import requests
from django.conf import settings
from requests_futures.sessions import FuturesSession
from django.http import HttpResponse, JsonResponse

from cachecontrol import CacheControl
from cachecontrol.heuristics import ExpiresAfter
from cachecontrol_django import DjangoCache

from api.models import Gene

cached_sess = CacheControl(
    requests.session(),
    cache=DjangoCache(),
    heuristic=ExpiresAfter(days=10)
)


# -------------------------------------------------------------
# --- SOCIBP acquisition endpoints
# -------------------------------------------------------------


def get_genes(request):
    # params: projection=SUMMARY&pageSize=100000&pageNumber=0&direction=ASC
    response = requests.get(settings.SOCIBP_API_URL + '/genes', params={
        'projection': 'SUMMARY',
        'pageSize': 100000,
        'pageNumber': '0',
        'direction': 'ASC'
    }, headers={
        # 'Authorization': 'Basic andre:tf12.57g'
    })

    if response.status_code != 200:
        return HttpResponse(response.content, status=response.status_code)

    return HttpResponse(response.content, content_type='text/json')


def get_changed_samples(request, gene, change):
    # TODO: either directly get # of patients/samples per study, orrr
    #  1. get the list of studies
    #  2. for each study, get patients/samples with change in gene

    # pre-step: look up the entrez gene id of the specified gene
    entrez_gene_id = Gene.objects.get(symbol=gene).entrez_id

    # create session for asynchronous requests
    session = FuturesSession()

    #
    # -- step 1. get study metadata
    # --------------------------------------------------------------------------------------
    resp_future = session.get(settings.SOCIBP_API_URL + '/studies')
    resp = resp_future.result()
    study_data = dict(
        (x['studyId'], x)
        for x in json.loads(resp.content)
    )

    # get molecular profiles for each study
    resp_future = session.post(settings.SOCIBP_API_URL + '/molecular-profiles/fetch', json={
        'studyIds': list(study_data.keys())
    })
    resp = resp_future.result()
    filtered_profiles = (x for x in json.loads(resp.content) if x['molecularAlterationType'] == 'MUTATION_EXTENDED')
    molecular_profiles = dict(
        (x[0], list(x[1]))
        for x in groupby(filtered_profiles, itemgetter('studyId'))
    )

    # get sample IDs which have mutation data
    # (we really only care about category: 'all_cases_with_mutation_data')
    resp_future = session.get(settings.SOCIBP_API_URL + '/sample-lists', params={
        'projection': 'SUMMARY',
        'pageSize': 10000000,
        'pageNumber': 0,
        'direction': 'ASC'
    })
    resp = resp_future.result()
    filtered_sample_lists = (x for x in json.loads(resp.content) if x['category'] == 'all_cases_with_mutation_data')
    sample_lists = dict(
        (x[0], list(x[1]))
        for x in groupby(filtered_sample_lists, itemgetter('studyId'))
    )

    # get mutation info for a molecular profile + sample lists
    mutations = defaultdict(list)
    resp_futures = []  # stores async handles so we can fire off many requests at once

    # fire off asynchronous requests for each study's mutation list
    for study_id, profiles in molecular_profiles.items():
        assert len(profiles) == 1
        profile = profiles[0]
        profile_id = profile['molecularProfileId']

        assert len(sample_lists[study_id]) == 1

        resp_future = session.post(settings.SOCIBP_API_URL + '/molecular-profiles/' + profile_id + '/mutations/fetch', json={
            'entrezGeneIds': [entrez_gene_id],
            'sampleListId': sample_lists[study_id][0]['sampleListId']
        })
        resp_futures.append(resp_future)

    # collect and reduce results into 'mutations'
    for resp_future in resp_futures:
        items = json.loads(resp_future.result().content)
        for item in (x for x in items if x['proteinChange'] == change):
            mutations[item['studyId']].append({
                'entrezGeneId': item['entrezGeneId'],
                'sampleId': item['sampleId'],
                'patientId': item['patientId'],
                'proteinChange': item['proteinChange']
            })

    # /index.do?Action=Submit&genetic_profile_ids=lille_prostate_rubin2019_mutations&case_set_id=lille_prostate_rubin2019_all&cancer_study_id=lille_prostate_rubin2019&gene_list=ALK&tab_index=tab_visualize&#mutation_details

    return JsonResponse({
        # 'studies': study_data,
        # 'molecular_profiles': molecular_profiles,
        # 'sample_lists': sample_lists,
        'mutations': [
            {
                'study': study_data[study_id],
                'authed_link': (
                    settings.SOCIBP_BASE_URL + '/index.do?Action=Submit&genetic_profile_ids=%(study_profile_id)s&case_set_id=%(study_id)s_all&cancer_study_id=%(study_id)s&gene_list=%(gene)s&tab_index=tab_visualize&#mutation_details' %
                    {
                        'study_id': study_id,
                        'study_profile_id': molecular_profiles[study_id][0]['molecularProfileId'],
                        'gene': gene
                    }
                ),
                'num_patients': len(set(x['patientId'] for x in mutations_list)),
                'num_samples': len(set(x['sampleId'] for x in mutations_list)),
            }
            for study_id, mutations_list in mutations.items()
        ]
    })
