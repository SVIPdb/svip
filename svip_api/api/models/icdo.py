# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey has `on_delete` set to the desired behavior.
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models

from api.models import Disease


class IcdOMorpho(models.Model):
    cell_type_code = models.TextField()
    icd_o_morpho_behavior = models.ForeignKey('IcdOMorphoBehavior', models.DO_NOTHING)
    icd_o_morpho_level = models.ForeignKey('IcdOMorphoLevel', models.DO_NOTHING)
    term = models.TextField()
    code_reference = models.TextField(blank=True, null=True)
    obs = models.BooleanField()
    additional_information = models.TextField(blank=True, null=True)
    created_on = models.DateTimeField(blank=True, null=True)
    user_created = models.BooleanField()
    morpho_version = models.ForeignKey('IcdOMorphoVersion', models.DO_NOTHING, db_column='morpho_version', blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'icd_o_morpho'


class IcdOMorphoBehavior(models.Model):
    behavior_code = models.IntegerField()
    behavior_description = models.TextField()

    class Meta:
        managed = False
        db_table = 'icd_o_morpho_behavior'


class IcdOMorphoLevel(models.Model):
    level = models.TextField()
    icd_o_level = models.BooleanField()

    class Meta:
        managed = False
        db_table = 'icd_o_morpho_level'


class IcdOMorphoVersion(models.Model):
    version = models.TextField()

    class Meta:
        managed = False
        db_table = 'icd_o_morpho_version'


class IcdOTopo(models.Model):
    topo_code = models.TextField(blank=True, null=True)
    topo_level = models.ForeignKey('IcdOTopoLevel', models.DO_NOTHING, blank=True, null=True)
    topo_term = models.TextField(blank=True, null=True)
    topo_version = models.ForeignKey('IcdOTopoVersion', models.DO_NOTHING, db_column='topo_version', blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'icd_o_topo'


class IcdOTopoApiDisease(models.Model):
    api_disease = models.ForeignKey(Disease, models.DO_NOTHING)
    icd_o_topo = models.ForeignKey(IcdOTopo, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'icd_o_topo_api_disease'
        unique_together = (('api_disease', 'icd_o_topo'),)


class IcdOTopoLevel(models.Model):
    level = models.TextField()

    class Meta:
        managed = False
        db_table = 'icd_o_topo_level'


class IcdOTopoVersion(models.Model):
    version = models.TextField()

    class Meta:
        managed = False
        db_table = 'icd_o_topo_version'
