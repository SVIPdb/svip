# Generated by Django 2.2.24 on 2021-06-29 11:01

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0122_auto_20210628_1546'),
    ]

    operations = [
        migrations.AlterField(
            model_name='curationreview',
            name='comment',
            field=models.TextField(default='', null=True),
        ),
    ]
