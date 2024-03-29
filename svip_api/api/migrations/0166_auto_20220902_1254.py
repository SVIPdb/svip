# Generated by Django 2.2.28 on 2022-09-02 12:54

from django.conf import settings
from django.db import migrations, models
import django_db_cascade.deletions


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0165_auto_20220824_0838'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='sibannotation1',
            name='evidence',
        ),
        migrations.RemoveField(
            model_name='sibannotation2',
            name='evidence',
        ),
        migrations.AlterField(
            model_name='curationreview',
            name='reviewer',
            field=models.ForeignKey(null=True, on_delete=django_db_cascade.deletions.DB_CASCADE, related_name='curation_reviews', to=settings.AUTH_USER_MODEL),
        ),
        migrations.DeleteModel(
            name='RevisedReview',
        ),
        migrations.DeleteModel(
            name='SIBAnnotation1',
        ),
        migrations.DeleteModel(
            name='SIBAnnotation2',
        ),
    ]
