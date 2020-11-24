from django.http import JsonResponse
from django.utils.datastructures import MultiValueDictKeyError

from api.models import Variant, Sample

BEACON_API_VERSION = "1.0.1"


def get_beacon_info(request):
    return {
        "id": "svip-beacon",
        "name": "SVIP Beacon",
        "apiVersion": BEACON_API_VERSION,
        "organization": {
            "id": "SVIP",
            "name": "Swiss Variant Interpretation Platform",
            "description": "tbc.",
            "address": "",
            "welcomeUrl": "https://svip.ch",
            "contactUrl": "mailto:feedback@svip.ch",
            "logoUrl": "https://svip.ch/media/Logo_SVIP.png",
            "info": None
        },
        "description": "This is a (test) SVIP beacon",
        "version": "v1",
        "welcomeUrl": "https://svip.ch",
        "alternativeUrl": "https://svip.ch",
        "createDateTime": "2019-07-01T00:00.000Z",
        "updateDateTime": "2019-07-01T00:00.000Z",
        "datasets": [{
            "id": "svip-public",
            "name": None,
            "description": "SVIP variant data",
            "assemblyId": "GRCh37",
            "createDateTime": None,
            "updateDateTime": None,
            "dataUseConditions": {
                "consentCodedataUse": {
                    "primaryCategory": {
                        "code": "NRES",
                        "description": "No restrictions on data use.",
                        "additionalConstraint": None
                    },
                    "secondaryCategories": [],
                    "requirements": [],
                    "version": "v1.0"
                }
            },
            "version": None,
            "variantCount": Variant.objects.count(),
            "callCount": 0,
            "sampleCount": Sample.objects.count(),  # patient samples
            "externalUrl": None,
            "info": [{
                "key": "accessType",
                "value": "PUBLIC"
            }, {
                "key": "authorized",
                "value": "true"
            }]
        }],
        "sampleAlleleRequests": [{
            "referenceName": "7",
            "start": 140453136,
            "startMin": None,
            "startMax": None,
            "end": None,
            "endMin": None,
            "endMax": None,
            "referenceBases": "A",
            "alternateBases": "T",
            "variantType": None,
            "assemblyId": "GRCh37",
            "datasetIds": None,
            "includeDatasetResponses": None
        }],
        "info": []
    }


def beacon(request):
    # reference: https://github.com/ga4gh-beacon/beacon-elixir#beacon
    return JsonResponse(get_beacon_info(request))


QUERY_PARAMS = {
    "assemblyId": {
        "required": True,
        "localField": "reference_name"
    },  # Assembly identifier (GRC notation, e.g. GRCh37).
    "referenceName": {
        "required": True,
        "localField": "chromosome"
    },  # Reference name (chromosome). Accepting values 1-22, X, Y, MT.
    "start": {
        "required": False,
        "localField": "start_pos"
    },  # Precise start coordinate position, allele locus (0-based, inclusive).
    "startMin": {
        "required": False,
        "localField": "start_pos__gte"
    },  # Minimum start coordinate
    "startMax": {
        "required": False,
        "localField": "start_pos__lte"
    },  # Minimum start coordinate
    "end": {
        "required": False,
        "localField": "end_pos"
    },  # Precise end coordinate (0-based, exclusive). See start.
    "endMin": {
        "required": False,
        "localField": "end_pos__gte"
    },  # Minimum end coordinate. See startMin.
    "endMax": {
        "required": False,
        "localField": "end_pos__lte"
    },  # Maximum end coordinate. See startMin.
    "referenceBases": {
        "required": True,
        "localField": "ref__regex"
    },  # Reference bases for this variant (starting from start). Accepted values: [ACGT]*.
    "alternateBases": {
        "required": False,
        "localField": "alt__regex"
    },  # The bases that appear instead of the reference bases. Accepted values: [ACGT]* or N.
    "variantType": {
        "required": False,
        "localField": None
    },
    # The variantType is used to denote e.g. structural variants. Optional: either alternateBases or variantType is required.
    "datasetIds": {
        "required": False,
        "localField": None
    },
    # Identifiers of datasets, as defined in BeaconDataset. If this field is None/not specified, all datasets should be queried. E.g. ?datasetIds=some-id&datasetIds=another-id.
    "includeDatasetResponses": {
        "required": False,
        "localField": None,
        "default": "NONE"
    },
    # Indicator of whether responses for individual datasets (datasetAlleleResponses) should be included in the response (BeaconAlleleResponse) to this request or not. If None (not specified), the default value of NONE is assumed. Accepted values: ALL, HIT, MISS, NONE.
}


class InvalidQueryParams(Exception):
    def __init__(self, *args, **kwargs):
        super(InvalidQueryParams, self).__init__(*args)
        self.payload = kwargs['payload']
        self.status = kwargs['status']


def perform_beacon_query(request, query_params):
    try:
        params = dict(
            (k, request.GET[k] if v['required'] else request.GET.get(k, None))
                for k, v in query_params.items()
        )

        # merge in default values for unspecified arguments
        params.update(
            dict((k, v['default']) for (k, v) in query_params.items() if params[k] is None and 'default' in v)
        )

    except MultiValueDictKeyError:
        raise InvalidQueryParams(payload={
            "beaconId": "svip-beacon",
            "error": "Required parameter missing in request",
            "apiVersion": BEACON_API_VERSION,
            "datasetAlleleResponses": None
        }, status=500)

    request_params = params.copy()

    # sanitize referenceBases, alternateBases and handle wildcards
    for k, v in [(k, params[k]) for k in ('referenceBases', 'alternateBases') if params[k] is not None]:
        for idx, ch in enumerate(v):
            if ch not in ('A', 'C', 'T', 'G', 'N'):
                raise InvalidQueryParams(payload={
                    "beaconId": "svip-beacon",
                    "error": "Invalid specifier encountered in %s at position %d: %s" % (k, idx, ch),
                    "apiVersion": BEACON_API_VERSION,
                    "datasetAlleleResponses": None
                }, status=500)

        # replace all the 'N's with single-character matches of A,C,T,G
        params[k] = r'^%s$' % v.replace('N', '[ACTG]')

    # actually perform the query against the SVIP variants
    svip_vars = Variant.objects.filter(
        **dict(
            (query_params[k]['localField'], v)
                for k, v in params.items()
                if v is not None and query_params[k]['localField'] is not None
        )
    ).values('name', 'hgvs_c', 'ref', 'alt')

    print("Query: %s" % svip_vars.query)

    # handle the includeDatasetResponses parameter
    var_exists = svip_vars.exists()

    if params['includeDatasetResponses'] == 'ALL' or (params['includeDatasetResponses'] == 'HIT' and var_exists):
        dataset_response = [{
            "datasetId": "svip-public",
            "exists": var_exists,
            "frequency": 0,
            "variantCount": svip_vars.count(),
            "callCount": Sample.objects.count() * 2,
            "sampleCount": Sample.objects.count(),
            "note": "tbc",
            "externalUrl": "https://svip.ch",
            "info": {
                "variant_names": [v for v in svip_vars]
            },
            "error": None
        }]
    elif params['includeDatasetResponses'] == 'HIT' and not var_exists or \
            params['includeDatasetResponses'] == 'MISS' and var_exists:
        # return an empty
        dataset_response = []
    else:
        # deal with "NONE", where we explicitly don't return any dataset results
        dataset_response = None

    return {
        "beaconId": "svip-beacon",
        "exists": var_exists,
        "error": None,
        "alleleRequest": request_params,
        "apiVersion": BEACON_API_VERSION,
        "datasetAlleleResponses": dataset_response
    }


def beacon_query(request):
    # reference: https://github.com/ga4gh-beacon/beacon-elixir#beaconquery
    try:
        return JsonResponse(perform_beacon_query(request, QUERY_PARAMS))
    except InvalidQueryParams as ex:
        return JsonResponse(ex.payload, status=ex.status)


