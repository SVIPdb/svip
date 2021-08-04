# Generated by Django 2.2.24 on 2021-07-29 12:59

from django.db import migrations, models
import django_db_cascade.deletions
import django_db_cascade.fields


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0135_merge_20210729_1257'),
    ]

    operations = [
        migrations.AlterField(
            model_name='curationreview',
            name='curation_entry',
            field=django_db_cascade.fields.ForeignKey(null=True, on_delete=django_db_cascade.deletions.DB_CASCADE, to='api.CurationEntry'),
        ),
        migrations.AlterField(
            model_name='variant',
            name='soid',
            field=models.TextField(default='', null=True, verbose_name='Sequence Ontology ID'),
        ),
    ]