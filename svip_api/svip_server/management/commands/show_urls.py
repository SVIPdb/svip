# Open django shell and do following.
from django.core.management import BaseCommand

import svip_server.urls as urls


class Command(BaseCommand):
    help = 'Shows all the URLs known to the top-level router'

    def show_urls(self, urllist, depth=0):
        for entry in urllist:
            self.stdout.write("%s%s" % ("  " * depth, entry.pattern))
            if hasattr(entry, 'url_patterns'):
                self.show_urls(entry.url_patterns, depth + 1)
                self.stdout.write("")

    def handle(self, *args, **options):
        self.show_urls(urls.urlpatterns)
