#!/usr/bin/env bash

# aggressively checks for errors, failing on the first (including errors within pipes)
set -e -o pipefail

# wait for postgres to wake up
until PGPASSWORD="$POSTGRES_PASSWORD" psql -d  "$POSTGRES_DB" -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -c '\q'; do # 2> /dev/null
  >&2 echo "Postgres is unavailable at $POSTGRES_HOST - sleeping"
  sleep 3
done

#pip install django_mkdocs

python manage.py migrate
python manage.py createcachetable

# attempt to create superuser if they don't already exist
python -c "import os
os.environ['DJANGO_SETTINGS_MODULE'] = 'svip_server.settings.development'
import django
django.setup()
from django.contrib.auth.management.commands.createsuperuser import get_user_model
if get_user_model().objects.filter(username='$DJANGO_SU_NAME'):
    print('Super user already exists, skipping...')
else:
    print('Creating super user...')
    get_user_model()._default_manager.db_manager('default').create_superuser(
        username='$DJANGO_SU_NAME',
        email='$DJANGO_SU_EMAIL',
        password='$DJANGO_SU_PASSWORD')
    print('Super user created...')"

# ensure static assets folder exists
python manage.py collectstatic --no-input

# ensure that the mock svip variants are present
# python manage.py populate_mock_svipdata

#(cd docs; mkdocs build --clean)

# and finally run the server
if [[ -n "${USE_DEV_SERVER}" ]]; then
    # this dev server is less efficient than gunicorn, but it auto-reloads on source changes
    # We should not do this since gunicorn has a reload option because its fu***ing slow.
    python manage.py runserver 0.0.0.0:8085
else
    #gunicorn = WSGIApplication()
    #gunicorn.load_wsgiapp = lambda: app
    #gunicorn.cfg.set('bind', '%s:%s' % (host, port))
    #gunicorn.cfg.set('workers', workers)
    #gunicorn.cfg.set('threads', workers)
    #gunicorn.cfg.set('pidfile', None)
    #gunicorn.cfg.set('worker_class', 'sync')
    #gunicorn.cfg.set('keepalive', 10)
    #gunicorn.cfg.set('accesslog', '-')
    #gunicorn.cfg.set('errorlog', '-')
    #gunicorn.cfg.set('reload', True)
    #gunicorn.chdir()
    #gunicorn.run()
    gunicorn svip_server.wsgi -b 0.0.0.0:8085 --reload -k gevent -w 16 --timeout 300
fi
