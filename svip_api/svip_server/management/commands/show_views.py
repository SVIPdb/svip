# Open django shell and do following.
from pprint import pprint

from django.core.management import BaseCommand
from django.urls import URLResolver, URLPattern

import svip_server.urls as urls
from django.conf import settings


class Command(BaseCommand):
    help = 'Shows all the Views known to the top-level router'

    def __init__(self, stdout=None, stderr=None, no_color=False):
        super().__init__(stdout=None, stderr=None, no_color=False)
        self.detail_views_list = []

    def get_all_view_names(self, urlpatterns):
        for pattern in urlpatterns:
            if isinstance(pattern, URLResolver):
                self.get_all_view_names(pattern.url_patterns)
            elif isinstance(pattern, URLPattern):
                self.detail_views_list.append(pattern.callback.__name__)

    def handle(self, *args, **options):
        all_urlpatterns = __import__(settings.ROOT_URLCONF).urls.urlpatterns
        self.get_all_view_names(all_urlpatterns)
        all_views_list = []

        # remove redundant entries and specific ones we don't care about
        for each in self.detail_views_list:
            if each not in "serve add_view change_view changelist_view history_view delete_view RedirectView":
                if each not in all_views_list:
                    all_views_list.append(each)

        pprint(all_views_list)
