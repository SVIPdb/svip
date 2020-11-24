from django.db import models
from django.utils.timezone import now


class DrugManager(models.Manager):
    def get_by_natural_key(self, common_name, user_created):
        return self.get(common_name=common_name, user_created=user_created)

class Drug(models.Model):
    common_name = models.TextField()
    medicine_name = models.TextField(null=True)
    active_substance = models.TextField(null=True)
    target_area = models.TextField(null=True)
    product_number = models.TextField(null=True)
    atc_code = models.TextField(null=True)

    user_created = models.BooleanField(default=False)
    created_on = models.DateTimeField(default=now, null=True)
    objects = DrugManager()

    def natural_key(self):
        return self.common_name, self.user_created

    class Meta:
        unique_together = ('common_name', 'user_created')

class DiseaseManager(models.Manager):
    def get_by_natural_key(self, name, user_created, localization):
        return self.get(name=name, user_created=user_created, localization=localization)

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

    objects = DiseaseManager()

    def natural_key(self):
        return self.name, self.user_created, self.localization

    def __str__(self):
        return "%s (id: %d)" % (self.name, self.id)
