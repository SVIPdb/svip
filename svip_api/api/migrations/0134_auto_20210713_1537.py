# Generated by Django 2.2.24 on 2021-07-13 15:37

from django.db import migrations
import django_db_cascade.deletions
import django_db_cascade.fields


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0133_auto_20210713_1415'),
    ]

    operations = [
        migrations.AlterField(
            model_name='curationreview',
            name='curation_entry',
            field=django_db_cascade.fields.ForeignKey(default=520, on_delete=django_db_cascade.deletions.DB_CASCADE, to='api.CurationEntry'),
        ),
    ]
