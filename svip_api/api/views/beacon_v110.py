from django.http import JsonResponse
from django.utils.datastructures import MultiValueDictKeyError

from api.models import Variant, Sample
import api.views.beacon as beacon101

BEACON_API_VERSION = "1.1.0"

QUERY_PARAMS_110 = beacon101.QUERY_PARAMS.copy()
# QUERY_PARAMS_110.update({
#     'mateName': {'required': False, 'localField': None, 'default': 'NOT_SUPPORTED'}
# })


def exists_and_not_empty(x):
    return x is not None and len(x) > 0


def beacon(request):
    # reference: https://github.com/ga4gh-beacon/beacon-elixir#beacon
    beacon101_response = beacon101.get_beacon_info(request).copy()

    # patch in parts that have changed in 1.1.0
    beacon101_response['apiVersion'] = BEACON_API_VERSION
    beacon101_response['datasets'][0]['info'] = {"accessType": "PUBLIC", "authorized": "true"}

    return JsonResponse(beacon101_response)


def beacon_query(request):
    print(QUERY_PARAMS_110)

    beacon101_response = beacon101.perform_beacon_query(request, QUERY_PARAMS_110)
    beacon101_response['apiVersion'] = BEACON_API_VERSION

    # refer to the following for examples of the handover fields used below:
    # https://github.com/ga4gh-beacon/specification/blob/8a24d3e53be45ec45e5f4e634f3c5343bad3c160/beacon.md#beacon-api-specification-v110

    if exists_and_not_empty(beacon101_response['datasetAlleleResponses']):
        # FIXME: we should generate some kind of info to reconstruct the query on our side,
        #  but that will require richer querying capabilities on our end...

        beacon101_response['datasetAlleleResponses'][0]["datasetHandover"] = [{
            "handoverType": {
                "id": "CUSTOM",
                "label": "Website"
            },
            "note": "SVIP public data interface",
            "url": "https://svip-dev.nexus.ethz.ch/"
        }]

    # TODO: figure out if there's a difference between the dataset and beacon handover for our case
    beacon101_response["beaconHandover"] = [{
        "handoverType": {
            "id": "CUSTOM",
            "label": "Website"
        },
        "note": "SVIP public data interface",
        "url": "https://svip-dev.nexus.ethz.ch/"
    }]

    return JsonResponse(beacon101_response)

def filtering_terms(request):
    return JsonResponse({
        "beaconId": "svip-public",
        "version": "v1",
        "apiVersion": BEACON_API_VERSION,
        "ontologyTerms": [{
            "ontology": "ega.dataset.technology",
            "term": "1",
            "label": "Affymetrix technology 2323"
        }, {
            "ontology": "ega.dataset.technology",
            "term": "2",
            "label": "Illumina technology 2323"
        }, {
            "ontology": "ega.dataset.technology",
            "term": "3",
            "label": "Illumina Genome Analyzer II technology 2323"
        }, {
            "ontology": "ega.dataset.technology",
            "term": "4",
            "label": "Illumina HiSeq 2000 technology"
        }, {
            "ontology": "ega.dataset.technology",
            "term": "5",
            "label": "Perlegen technology 2323"
        }]
    })

