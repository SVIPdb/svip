# Generated by Django 2.2.24 on 2021-10-18 08:47

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0150_merge_20211015_1304'),
    ]

    operations = [
        migrations.AddField(
            model_name='gene',
            name='summary',
            field=models.TextField(blank=True, null=True),
        ),
    ]
