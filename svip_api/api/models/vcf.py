from api.models.genomic import Variant
from django.db import models


class VCF(models.Model):
    name = models.TextField()
    variants = models.ManyToManyField(to=Variant)
    sample = models.ForeignKey(to=Sample, on_delete=DB_CASCADE)

class Institution(models.Model):
    name = models.TextField()
    phone_num = models.TextField()
    email = models.TextField()
    medical_service = models.TextField(verbose_name="Medical service")

class Sample(models.Model):
    sample_id = models.TextField(verbose_name="Sample ID")
    identifier = models.ForeignKey(to=Institution, on_delete=DB_CASCADE)
    year_of_birth = models.IntegerField(verbose_name="Year of birth")
    gender = models.TextField(verbose_name="Gender")
    sequencing_date = models.DateField(verbose_name="Sequencing date")
    provider_annotation = models.TextField(verbose_name="Provider annotation")
    sample_tissue = models.TextField(verbose_name="Sample Tissue")

class User(models.Model):
    institution = models.ForeignKey(to=Institution, on_delete=DB_CASCADE)