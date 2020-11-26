# Generated by Django 2.1.3 on 2019-06-07 13:52
from django.contrib.auth import get_user_model
from django.db import migrations
from django.db.migrations import RunPython

GROUPS = {
    'clinicians': {
        'permissions': ['view_sample']
    },
    'curators': {
        'permissions': ['change_curationentry', 'delete_curationentry', 'view_curationentry']
    }
}


def create_groups(apps, schema_editor):
    Group = apps.get_model('auth', 'Group')
    Permission = apps.get_model('auth', 'Permission')

    for groupname, v in GROUPS.items():
        g, created = Group.objects.get_or_create(name=groupname)
        if created:
            g.save()
        # ensure the permissions exist, regardless
        g.permissions.set([p for p in Permission.objects.filter(codename__in=v['permissions'])])


def drop_groups(apps, schema_editor):
    Group = apps.get_model('auth', 'Group')
    Group.objects.filter(name__in=GROUPS.keys()).delete()


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0054_collapsed_associations_view'),
    ]

    operations = [
        RunPython(create_groups, reverse_code=drop_groups)
    ]