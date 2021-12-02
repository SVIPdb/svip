from django.db import migrations


# ger rid of "chr" substring found at the beginning of the chromosome field of several variants
def harmonize_chromosome_fields(apps, schema_editor):
    Variant = apps.get_model('api', 'Variant')

    for variant in Variant.objects.filter(chromosome__icontains="chr").all():
        variant.chromosome = variant.chromosome[3:]
        variant.save()


def reverse(apps, schema_editor):
    pass


class Migration(migrations.Migration):
    dependencies = [
        ('api', '0157_drop_api_disease_contraint'),
    ]

    operations = [
        migrations.RunPython(harmonize_chromosome_fields, reverse_code=reverse)
    ]
