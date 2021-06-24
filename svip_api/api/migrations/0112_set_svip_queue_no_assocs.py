# Generated by Django 2.2.13 on 2021-06-23 16:37

from django.db import migrations

def forward_op(apps, schema_editor):
    Source = apps.get_model('api', 'Source')
    Source.objects.filter(name='svip_queue').update(no_associations=True)

def reverse_op(apps, schema_editor):
    Source = apps.get_model('api', 'Source')
    Source.objects.filter(name='svip_queue').update(no_associations=False)

class Migration(migrations.Migration):

    dependencies = [
        ('api', '0111_source_no_associations'),
    ]

    operations = [
        migrations.RunPython(forward_op, reverse_code=reverse_op)
    ]
