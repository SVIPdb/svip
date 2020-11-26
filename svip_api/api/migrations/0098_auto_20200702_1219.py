# Generated by Django 2.2.4 on 2020-07-02 12:19

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0097_auto_20200702_1020'),
    ]

    operations = [
        migrations.AlterModelOptions(
            name='curationentry',
            options={'verbose_name': 'Curation Entry', 'verbose_name_plural': 'Curation Entries'},
        ),
        migrations.AlterModelOptions(
            name='diseaseinsvip',
            options={'verbose_name': 'Disease in SVIP', 'verbose_name_plural': 'Diseases in SVIP'},
        ),
        migrations.AlterModelOptions(
            name='historicalcurationentry',
            options={'get_latest_by': 'history_date', 'ordering': ('-history_date', '-history_id'), 'verbose_name': 'historical Curation Entry'},
        ),
        migrations.AlterModelOptions(
            name='historicalvariantinsvip',
            options={'get_latest_by': 'history_date', 'ordering': ('-history_date', '-history_id'), 'verbose_name': 'historical Variant in SVIP'},
        ),
        migrations.AlterModelOptions(
            name='variantcuration',
            options={'ordering': ('id',)},
        ),
        migrations.AlterModelOptions(
            name='variantinsvip',
            options={'verbose_name': 'Variant in SVIP', 'verbose_name_plural': 'Variants in SVIP'},
        ),
    ]