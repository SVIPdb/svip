from django.db import models


class Drug(models.Model):
    common_name = models.TextField()
    medicine_name = models.TextField()
    active_substance = models.TextField()
    target_area = models.TextField()
    product_number = models.TextField()
    atc_code = models.TextField(null=True)


class Disease(models.Model):
    name = models.TextField()
    icdo_code = models.TextField(null=True)
