# Generated by Django 2.2.24 on 2021-08-06 14:38

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0136_auto_20210729_1259'),
    ]

    operations = [
        migrations.AlterField(
            model_name='submittedvariant',
            name='requestor',
            field=models.TextField(blank=True, help_text='If for_curation_request is true, identifies who asked for this variant to be submitted', null=True),
        ),
    ]
