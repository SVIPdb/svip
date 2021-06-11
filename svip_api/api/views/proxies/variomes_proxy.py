import requests
from django.http import HttpResponse, JsonResponse

from cachecontrol import CacheControl
from cachecontrol.heuristics import ExpiresAfter
from cachecontrol_django import DjangoCache
from django.views.decorators.gzip import gzip_page
from django.conf import settings

cached_sess = CacheControl(
    requests.session(),
    cache=DjangoCache(),
    heuristic=ExpiresAfter(seconds=30)
)


@gzip_page
def variomes_single_ref(request):
    # proxy requests to variomes server
    api = settings.VARIOMES_API if hasattr(
        settings, 'VARIOMES_API') else 'https://candy.hesge.ch/Variomes/api'
    response = cached_sess.get(
        f"{api}/fetchLit.jsp", params=request.GET, verify=False)

    if response.status_code != 200:
        return HttpResponse(response.content, status=response.status_code)

    return JsonResponse(response.json())


@gzip_page
def variomes_search(request):
    # proxy requests to variomes server
    api = settings.VARIOMES_API if hasattr(
        settings, 'VARIOMES_API') else 'https://candy.hesge.ch/Variomes/api'
    response = cached_sess.get(
        f"{api}/rankLit2.jsp", params=request.GET, verify=False)

    if response.status_code != 200:
        return HttpResponse(response.content, status=response.status_code)

    return JsonResponse(response.json())
