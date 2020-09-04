from .base import *

DEBUG = False

# put in some admins who should receive emails if things go wrong
if 'DJANGO_SU_NAME' in os.environ and 'DJANGO_SU_EMAIL' in os.environ:
    ADMINS = [(
        os.environ['DJANGO_SU_NAME'], os.environ['DJANGO_SU_EMAIL']
    )]
