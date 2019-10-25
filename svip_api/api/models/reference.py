from django.db import models


class Drug(models.Model):
    common_name = models.TextField()
    medicine_name = models.TextField()
    active_substance = models.TextField()
    target_area = models.TextField()
    product_number = models.TextField()
    atc_code = models.TextField(null=True)


class Disease(models.Model):
    localization = models.TextField()
    abbreviation = models.TextField(null=True)
    name = models.TextField()
    topo_code = models.TextField(null=True)
    morpho_code = models.TextField(null=True)
    snomed_code = models.TextField(null=True)
    snomed_name = models.TextField(null=True)
    details = models.TextField(null=True)

    def __str__(self):
        return "%s (id: %d)" % (self.name, self.id)
