import re

import requests
from django.http import HttpResponse, JsonResponse

from cachecontrol import CacheControl
from cachecontrol.heuristics import ExpiresAfter
from cachecontrol_django import DjangoCache


cached_sess = CacheControl(
    requests.session(),
    cache=DjangoCache(),
    heuristic=ExpiresAfter(days=10)
)

FORBIDDEN_HEADERS = [x.lower() for x in [
    "Connection",
    "Keep-Alive",
    "Proxy-Authenticate",
    "Proxy-Authorization",
    "TE",
    "Trailers",
    "Transfer-Encoding",
    "Upgrade",
]]


# -------------------------------------------------------------
# --- generic proxying of swiss_po requests
# -------------------------------------------------------------

def swisspo_request(request, path):
    payload = (request.GET if request.method == 'GET' else request.POST).copy()
    payload['get_option'] = 'BRAF'

    target_url = 'http://swiss-po.ch/%s' % path
    print("Accessing %s" % target_url)

    resp = cached_sess.request(
        method='POST',
        url=target_url,
        headers={key: value for (key, value) in request.headers.items() if key != 'Host'},
        data=payload,
        cookies=request.COOKIES,
        allow_redirects=False
    )

    excluded_headers = ['content-encoding', 'content-length', 'transfer-encoding', 'connection'] + FORBIDDEN_HEADERS
    headers = [
        (name, value) for (name, value) in resp.raw.headers.items()
        if name.lower() not in excluded_headers
    ]

    final_resp = HttpResponse(resp.content, status=resp.status_code)
    for k, v in headers:
        final_resp[k] = v

    return final_resp


# -------------------------------------------------------------
# --- translating steps of the swiss-po request pipeline
# -------------------------------------------------------------

# the pipeline consists of the following steps:
#  1) POST to http://swiss-po.ch/includes/main/fetch_data_pdb.php {get_option: BRAF} to get HTML dropdown of PDBs for this gene
#  2) POST to http://swiss-po.ch/includes/main/fetch_data_link.php {get_option: BRAF} to get links to uni/nexprot for this gene
#  3) POST to http://swiss-po.ch/includes/main/fetch_data_pdb_table.php {option_protein: BRAF, option_threshold: 9} to get
#     some kind of response to put in a "select PDB" panel that we never actually see...?
#  4) POST to http://swiss-po.ch/includes/main/fetch_data_fasta.php {get_option: BRAF} to get the name of the FASTA file
#  5) POST to http://swiss-po.ch/includes/main/fetch_residueNumbers.php {option_pdbId: 5HIE, option_chain: A} to get
#     something that looks like "449-722??separator??BRAF/PDB/5HIE.A.prot_corrected" (using the first PDB from step 1 or the contents of a cookie)
#  6) POST to http://swiss-po.ch/includes/main/fetch_data_pdb_info3D.php {get_option: 5HIE} to get an HTML blob
#     about the PDB to display in the tooltip above NGL.
#  7) GET http://swiss-po.ch/data/BRAF/MUSCLE_BRAF_ordered_aligned.fasta to get FASTA data (using name from step 4)
#  8) GET http://swiss-po.ch/data/BRAF/PDB/5HIE.A.prot_corrected.pdb to get PDB (using name from step 5)


def get_pdbs(request, protein):
    """
    Get a list of PDBs from Swiss-PO for a given protein
    :param request: the Django/WSGI request object
    :param protein: a HUGO gene symbol, e.g. "BRAF"
    :return: an array of {pdb, chain} objects identifying the RCSB PDB ID and relevant chains for that protein
    """
    response = requests.post('http://swiss-po.ch/includes/main/fetch_data_pdb.php', data={
        'get_option': protein
    })

    if response.status_code != 200:
        return HttpResponse(response.content, status=response.status_code)

    return JsonResponse([
        {'pdb': x[0], 'chain': x[1]}
        for x in re.findall(r'<option>([0-9A-Z]+) ([A-Z])?</option>', response.content.decode("utf-8"))
    ], safe=False)


def get_residues(request, pdb_id, chain):
    """
    For a given pdbID and chain, get the pdb filename and residues present in the structure
    :param request: the Django/WSGI request object
    :param pdb_id: a RCSB PDB ID, e.g. "5HIE"
    :param chain: a chain identifier, e.g. "A"
    :return: an array of {pdb, chain} objects identifying the RCSB PDB ID and relevant chains for that protein
    """
    response = requests.post('http://swiss-po.ch/includes/main/fetch_residueNumbers.php', data={
        'option_pdbId': pdb_id, 'option_chain': chain
    })

    if response.status_code != 200:
        return HttpResponse(response.content, status=response.status_code)

    response_data = response.content.decode("utf-8").strip()
    print(response_data)

    residues, filename = response_data.split('??separator??')
    residue_min, residue_max = [int(x) for x in residues.split('-')]

    return JsonResponse({
        'residue_range': {'min': residue_min, 'max': residue_max},
        'pdb_filename': filename
    })


def get_pdb_data(request, pdb_path):
    response = requests.get('http://swiss-po.ch/data/%s.pdb' % pdb_path)

    if response.status_code != 200:
        return HttpResponse(response.content, status=response.status_code)

    return HttpResponse(response.content, content_type='text/plain')
