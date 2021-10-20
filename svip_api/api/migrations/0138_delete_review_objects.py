from django.db import migrations


def delete_review_objects(apps, schema_editor):
    CurationEntry = apps.get_model('api', 'CurationEntry')
    CurationReview = apps.get_model('api', 'CurationReview')
    SIBAnnotation = apps.get_model('api', 'SIBAnnotation')
    CurationEvidence = apps.get_model('api', 'CurationEvidence')
    CurationAssociation = apps.get_model('api', 'CurationAssociation')

    for curation in CurationEntry.objects.all():
        curation.curation_evidence = None
        curation.save()
    CurationReview.objects.all().delete()
    SIBAnnotation.objects.all().delete()
    CurationEvidence.objects.all().delete()
    CurationAssociation.objects.all().delete()


def reverse(apps, schema_editor):
    pass


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0137_auto_20210813_1402'),
    ]

    operations = [
        migrations.RunPython(delete_review_objects, reverse_code=reverse)
    ]
