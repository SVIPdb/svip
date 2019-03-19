#!/usr/bin/env bash

# wait for postgres to wake up
until PGPASSWORD="$POSTGRES_PASSWORD" psql -d  "$POSTGRES_DB" -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -c '\q'; do # 2> /dev/null
  >&2 echo "Postgres is unavailable at $POSTGRES_HOST - sleeping"
  sleep 1
done

python manage.py migrate

# attempt to create superuser if they don't already exist
python -c "import os
os.environ['DJANGO_SETTINGS_MODULE'] = 'svip_server.settings'
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
python manage.py populate_mock_svipdata

# and finally run the server
gunicorn svip_server.wsgi -b 0.0.0.0:8085
