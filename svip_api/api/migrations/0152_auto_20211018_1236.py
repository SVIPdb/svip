# Generated by Django 2.2.24 on 2021-10-18 12:36

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion
import django_db_cascade.deletions


class Migration(migrations.Migration):

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ('api', '0151_gene_summary'),
    ]

    operations = [
        migrations.AlterField(
            model_name='summarycomment',
            name='owner',
            field=models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, to=settings.AUTH_USER_MODEL),
        ),
        migrations.AlterField(
            model_name='summarycomment',
            name='variant',
            field=models.ForeignKey(on_delete=django_db_cascade.deletions.DB_CASCADE, to='api.Variant'),
        ),
        migrations.AlterField(
            model_name='summarydraft',
            name='owner',
            field=models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, to=settings.AUTH_USER_MODEL),
        ),
        migrations.AlterField(
            model_name='summarydraft',
            name='variant',
            field=models.ForeignKey(on_delete=django_db_cascade.deletions.DB_CASCADE, to='api.Variant'),
        ),
        migrations.CreateModel(
            name='GeneSummaryDraft',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('content', models.TextField(default='')),
                ('gene', models.ForeignKey(on_delete=django_db_cascade.deletions.DB_CASCADE, to='api.Gene')),
                ('owner', models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, to=settings.AUTH_USER_MODEL)),
            ],
        ),
    ]
