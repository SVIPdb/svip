# Generated by Django 2.2.13 on 2021-06-22 15:23

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0127_auto_20210622_0953'),
    ]

    operations = [
        migrations.AddField(
            model_name='curationevidence',
            name='annotated_effect',
            field=models.TextField(default=''),
        ),
        migrations.AddField(
            model_name='curationevidence',
            name='annotated_tier',
            field=models.TextField(default=''),
        ),
    ]
