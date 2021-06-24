# Generated by Django 2.2.13 on 2021-06-23 16:36

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0110_add_svip_queue_source'),
    ]

    operations = [
        migrations.AddField(
            model_name='source',
            name='no_associations',
            field=models.BooleanField(default=False, help_text="Indicates that this source doesn't contain evidence. If true, filters this source out from variantinsource queries"),
        ),
    ]
