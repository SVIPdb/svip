import requests
from django.http import HttpResponse, JsonResponse

from cachecontrol import CacheControl, CacheControlAdapter
from cachecontrol.heuristics import ExpiresAfter
from cachecontrol_django import DjangoCache

adapter = CacheControlAdapter(heuristic=ExpiresAfter(days=1))
cached_sess = CacheControl(requests.session(), cache=DjangoCache())
cached_sess.mount('http://', adapter)


def variomes_single_ref(request):
    # proxy requests to candy
    response = cached_sess.get('http://candy.hesge.ch/Variomes/api/getOnePublication.jsp', params=request.GET)

    if response.status_code != 200:
        return HttpResponse(response.content, status=response.status_code)

    return JsonResponse(response.json())
