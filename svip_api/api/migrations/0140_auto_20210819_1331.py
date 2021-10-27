# Generated by Django 2.2.24 on 2021-08-19 13:31

from django.db import migrations, models
import django_db_cascade.deletions


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0139_auto_20210819_1323'),
    ]

    operations = [
        migrations.AlterField(
            model_name='sibannotation1',
            name='evidence',
            field=models.OneToOneField(on_delete=django_db_cascade.deletions.DB_CASCADE, related_name='annotation1', to='api.CurationEvidence'),
        ),
    ]