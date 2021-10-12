import requests
from django.conf import settings
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
    response = cached_sess.get('%s/fetchLit.jsp' % settings.VARIOMES_BASE_URL,
                               params=request.GET, verify=settings.VARIOMES_VERIFY_REQUESTS)

    if response.status_code != 200:
        return HttpResponse(response.content, status=response.status_code)

    return JsonResponse(response.json())


@gzip_page
def variomes_search(request):

    # proxy requests to variomes server
    print('--variomes request--', '%s/rankLit.jsp' %
          settings.VARIOMES_BASE_URL, request.GET)
    response = cached_sess.get('%s/rankLit.jsp' % settings.VARIOMES_BASE_URL,
                               params=request.GET, verify=settings.VARIOMES_VERIFY_REQUESTS)

    if response.status_code != 200:
        return HttpResponse(response.content, status=response.status_code)

    return JsonResponse(response.json())
