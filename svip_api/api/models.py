from django.db import models


class Gene(models.Model):
    gene_id = models.BigIntegerField()
    hugo_name = models.CharField(max_length=10)


class Variant(models.Model):
    gene = models.ForeignKey(to=Gene, on_delete='cascade')
    hgvs_cdna = models.TextField(null=False)
