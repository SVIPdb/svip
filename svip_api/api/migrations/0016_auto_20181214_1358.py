# Generated by Django 2.1.3 on 2018-12-14 13:58

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0015_auto_20181206_0843'),
    ]

    operations = [
        migrations.AddField(
            model_name='variant',
            name='isoform',
            field=models.CharField(max_length=120, null=True),
        ),
        migrations.AddField(
            model_name='variant',
            name='refseq',
            field=models.CharField(max_length=60, null=True),
        ),
    ]