import logging

from .base import *

DEBUG = True
USE_NPLUSONE = False # if true, annotates all db requests with N+1 checking logic (expensive, not that reliable)

INSTALLED_APPS += [
    'debug_toolbar'
]

MIDDLEWARE += [
    'debug_toolbar.middleware.DebugToolbarMiddleware'
]

if USE_NPLUSONE:
    INSTALLED_APPS += ['nplusone.ext.django']
    MIDDLEWARE += ['nplusone.ext.django.NPlusOneMiddleware']

# django debug toolbar will only be shown for clients from here:
# (the socket import allows us to show it when django is running inside docker)
import socket

INTERNAL_IPS = [
    '127.0.0.1',
    'localhost',
    (socket.gethostbyname(socket.gethostname()))[:-1] + '1'
]

# we need to use structlog, not log
# NPLUSONE_LOGGER = logging.getLogger('nplusone')
NPLUSONE_LOG_LEVEL = logging.WARN
NPLUSONE_VERBOSE = True
NPLUSONE_LOCAL_STACK = True

LOGGING = {
    'version': 1,
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
        },
    },
    'loggers': {
        'nplusone': {
            'handlers': ['console'],
            'level': 'WARN',
        },
    },
}

# LOGGING = {
#     'version': 1,
#     'filters': {
#         'require_debug_true': {
#             '()': 'django.utils.log.RequireDebugTrue',
#         }
#     },
#     'handlers': {
#         'console': {
#             'level': 'DEBUG',
#             'filters': ['require_debug_true'],
#             'class': 'logging.StreamHandler',
#         }
#     },
#     'loggers': {
#         'django.db.backends': {
#             'level': 'DEBUG',
#             'handlers': ['console'],
#         }
#     }
# }
