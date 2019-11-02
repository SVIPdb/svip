from .base import *

DEBUG = True

INSTALLED_APPS += [
    'debug_toolbar',
]

MIDDLEWARE += [
    'debug_toolbar.middleware.DebugToolbarMiddleware',
]

# django debug toolbar will only be shown for clients from here:
# (the socket import allows us to show it when django is running inside docker)
import socket

INTERNAL_IPS = [
    '127.0.0.1',
    'localhost',
    (socket.gethostbyname(socket.gethostname()))[:-1] + '1'
]
