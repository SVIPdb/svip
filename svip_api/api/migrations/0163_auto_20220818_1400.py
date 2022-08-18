# Generated by Django 2.2.28 on 2022-08-18 14:00

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion
import django_db_cascade.deletions
import django_db_cascade.fields


class Migration(migrations.Migration):

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ('api', '0162_auto_20220812_1339'),
    ]

    operations = [
        migrations.CreateModel(
            name='SubmissionEntry',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('type_of_evidence', models.TextField(verbose_name='Type of evidence')),
                ('drug', models.TextField(null=True)),
                ('effect', models.TextField(default='Not yet annotated')),
                ('tier', models.TextField(default='Not yet annotated')),
                ('disease', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, to='api.Disease')),
                ('owner', models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, to=settings.AUTH_USER_MODEL)),
                ('variant', models.ForeignKey(on_delete=django_db_cascade.deletions.DB_CASCADE, related_name='submission_entries', to='api.Variant')),
            ],
        ),
        migrations.AddField(
            model_name='curationentry',
            name='submission_entry',
            field=django_db_cascade.fields.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, to='api.SubmissionEntry'),
        ),
        migrations.AddField(
            model_name='curationreview',
            name='submission_entry',
            field=models.ForeignKey(null=True, on_delete=django_db_cascade.deletions.DB_CASCADE, related_name='curation_reviews', to='api.SubmissionEntry'),
        ),
        migrations.AddField(
            model_name='historicalcurationentry',
            name='submission_entry',
            field=django_db_cascade.fields.ForeignKey(blank=True, db_constraint=False, null=True, on_delete=django.db.models.deletion.DO_NOTHING, related_name='+', to='api.SubmissionEntry'),
        ),
    ]
