from .base import *

DEBUG = True

# put in some admins who should receive emails if things go wrong
if 'DJANGO_SU_NAME' in os.environ and 'DJANGO_SU_EMAIL' in os.environ:
    ADMINS = [(
        os.environ['DJANGO_SU_NAME'], os.environ['DJANGO_SU_EMAIL']
    )]

# enable logging, too
LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "root": {"level": "INFO", "handlers": ["file"]},
    "handlers": {
        "file": {
            "level": "INFO",
            "class": "logging.FileHandler",
            "filename": "/var/log/django.log",
            "formatter": "app",
        },
    },
    "loggers": {
        "django": {
            "handlers": ["file"],
            "level": "INFO",
            "propagate": True
        },
    },
    "formatters": {
        "app": {
            "format": (
                u"%(asctime)s [%(levelname)-8s] "
                "(%(module)s.%(funcName)s) %(message)s"
            ),
            "datefmt": "%Y-%m-%d %H:%M:%S",
        },
    },
}
