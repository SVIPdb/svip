# Generated by Django 2.2.24 on 2021-07-04 12:08

from django.db import migrations, models
import django_db_cascade.deletions


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0131_auto_20210702_1533'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='curationevidence',
            name='annotated_effect',
        ),
        migrations.RemoveField(
            model_name='curationevidence',
            name='annotated_tier',
        ),
        migrations.CreateModel(
            name='SIBAnnotation',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('effect', models.TextField(default='Not yet annotated', null=True)),
                ('tier', models.TextField(default='Not yet annotated', null=True)),
                ('evidence', models.OneToOneField(on_delete=django_db_cascade.deletions.DB_CASCADE, related_name='annotation', to='api.CurationEvidence')),
            ],
        ),
    ]