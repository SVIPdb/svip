from django.db import models
from django.utils.timezone import now

from api.utils import model_field_null


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

    def get_queryset(self):
        # we'll always need at least icd_o_morpho, so select it ahead of time
        return super(DiseaseManager, self).get_queryset().select_related('icd_o_morpho')

class Disease(models.Model):
    created_on = models.DateTimeField(blank=True, null=True)
    icd_o_morpho = models.ForeignKey('IcdOMorpho', models.DO_NOTHING, blank=True, null=True)

    objects = DiseaseManager()

    def natural_key(self):
        # previously, natural keys where a tuple of (disease name, user-created flag, localization),
        # but now only the name is easily accessible
        return self.icd_o_morpho.term, False, 'n/a'

    def __str__(self):
        if model_field_null(self, 'icd_o_morpho'):
            return "%s (id: %d)" % ("*unknown*", self.id)

        return "%s (id: %d)" % (self.icd_o_morpho.term, self.id)

    # add in a bunch of stub model methods that allow the serializer to keep returning the old disease format in the API

    def localization(self):
        if model_field_null(self, 'icdotopoapidisease_set'):
            return None

        return "; ".join(self.icdotopoapidisease_set.values_list('icd_o_topo__topo_term', flat=True))

    def abbreviation(self):
        return None

    def name(self):
        if model_field_null(self, 'icd_o_morpho'):
            return None

        return self.icd_o_morpho.term

    def topo_code(self):
        if model_field_null(self, 'icdotopoapidisease_set'):
            return None

        return "; ".join(self.icdotopoapidisease_set.values_list('icd_o_topo__topo_code', flat=True))

    def morpho_code(self):
        if model_field_null(self, 'icd_o_morpho'):
            return None

        return self.icd_o_morpho.cell_type_code

    def snomed_code(self):
        return None

    def snomed_name(self):
        return None

    def details(self):
        return None

    def user_created(self):
        return False
