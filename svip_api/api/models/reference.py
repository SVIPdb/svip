from django.db import models
from django.utils.timezone import now


class Drug(models.Model):
    common_name = models.TextField()
    medicine_name = models.TextField(null=True)
    active_substance = models.TextField(null=True)
    target_area = models.TextField(null=True)
    product_number = models.TextField(null=True)
    atc_code = models.TextField(null=True)

    user_created = models.BooleanField(default=False)
    created_on = models.DateTimeField(default=now, null=True)


class Disease(models.Model):
    localization = models.TextField(null=True)
    abbreviation = models.TextField(null=True)
    name = models.TextField()
    topo_code = models.TextField(null=True)
    morpho_code = models.TextField(null=True)
    snomed_code = models.TextField(null=True)
    snomed_name = models.TextField(null=True)
    details = models.TextField(null=True)

    user_created = models.BooleanField(default=False)
    created_on = models.DateTimeField(default=now, null=True)

    def __str__(self):
        return "%s (id: %d)" % (self.name, self.id)
