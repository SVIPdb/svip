# Generated by Django 2.2.24 on 2021-07-13 14:15

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0132_auto_20210704_1208'),
    ]

    operations = [
        migrations.AlterField(
            model_name='curationentry',
            name='curation_evidences',
            field=models.ManyToManyField(default=None, related_name='curation_entries', to='api.CurationEvidence'),
        ),
    ]
