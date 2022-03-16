# Generated by Django 2.2.24 on 2022-01-06 07:51

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0158_harmonize_chromosome_fields'),
    ]

    operations = [
        migrations.AddField(
            model_name='curationreview',
            name='draft',
            field=models.BooleanField(default=False),
        ),
        migrations.AddField(
            model_name='revisedreview',
            name='draft',
            field=models.BooleanField(default=False),
        ),
        migrations.AddField(
            model_name='sibannotation1',
            name='draft',
            field=models.BooleanField(default=False),
        ),
        migrations.AddField(
            model_name='sibannotation2',
            name='draft',
            field=models.BooleanField(default=False),
        ),
    ]