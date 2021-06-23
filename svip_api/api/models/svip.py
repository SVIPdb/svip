from collections import OrderedDict
from enum import Enum
from itertools import chain

from django.conf import settings
from django.contrib.postgres.fields import ArrayField, JSONField
from django.db import connection, models
from django.db.models.base import ModelBase
from django.db.models.signals import post_save, pre_save
from django.dispatch import receiver
from django.utils.timezone import now
from django_db_cascade.deletions import DB_CASCADE
from django_db_cascade.fields import ForeignKey
from simple_history.models import HistoricalRecords

from api.models.genomic import Variant
from api.models.reference import Disease
from api.permissions import (ALLOW_ANY_CURATOR, CURATOR_ALLOWED_ROLES, PUBLIC_VISIBLE_STATUSES)
from api.utils import dictfetchall


class SVIPTableBase(ModelBase):
    """
    Allows us to change the prefix of created tables in a single place.

    Borrowed with modifications from https://stackoverflow.com/a/53374381/346905
    """
    def __new__(mcs, name, bases, attrs, **kwargs):
        if name != "SVIPModel":
            class MetaB:
                db_table = "svip_" + name.lower()

            # copy existing non-special fields in the meta into the new meta
            if 'Meta' in attrs:
                for field in [a for a in dir(attrs["Meta"]) if not a.startswith('__')]:
                    setattr(MetaB, field, getattr(attrs["Meta"], field))

            attrs["Meta"] = MetaB

        r = super().__new__(mcs, name, bases, attrs, **kwargs)
        return r


class SVIPModel(models.Model, metaclass=SVIPTableBase):
    class Meta:
        abstract = True


class SVIPReviewStatuses(Enum):
    LOADED = "Loaded"
    CURATED = "Curated"
    REVIEWED = "Reviewed"


# ================================================================================================================
# === Variant Aggregation
# ================================================================================================================

class VariantInSVIPManager(models.Manager):
    def prune_orphans(self):
        """
        Removes entries that have no derivative data.

        In this case, 'orphaned' entries are VariantInSVIP entries which have no summary and for which no
        DiseaseInSVIP exists.

        :return: the number of removed entries
        """

        return self.get_queryset().filter(
            summary__isnull=True,
            diseaseinsvip__isnull=True
        ).delete()

class VariantInSVIP(models.Model):
    """
    Represents SVIP information about a variant. While this could conceivably be handled by VariantInSource,
    it's possible that the SVIP info's structure, operations, and access restrictions will diverge significantly
    from the public data.

    Also, the SVIP-specific data model is still very much a work-in-progress, so I figure it doesn't make sense
    to devote a lot of time to engineering a normalized data model here. Instead, we just load the contents of the
    mock SVIP variants file into 'data' for each variant.
    """
    variant = models.OneToOneField(to=Variant, on_delete=DB_CASCADE)
    data = JSONField(default=dict)

    # contains a summary from the curators about this variant
    summary = models.TextField(null=True, blank=True)

    objects = VariantInSVIPManager()

    history = HistoricalRecords(cascade_delete_history=True)


    def tissue_counts(self):
        # FIXME: figure out how to do this with the ORM someday
        # TODO: check if correct
        with connection.cursor() as cursor:
            cursor.execute("""
            select
                Q.sample_tissue as name,
                sum(Q.cnt)::integer as count,
                jsonb_agg(json_build_object('name', Q.disease, 'count', Q.cnt)) as diseases
            from (
                select sample_tissue, m.term as disease, count(*) as cnt
                from svip_sample sv
                inner join svip_diseaseinsvip d on d.id=sv.disease_in_svip_id
                inner join api_disease ad on ad.id=d.disease_id
                inner join api_variantinsvip av on d.svip_variant_id = av.id
                inner join icd_o_morpho m on ad.id = m.id
                where svip_variant_id=%s
                group by sample_tissue, term
                ) as Q
            group by Q.sample_tissue
            """, [self.id])

            return dictfetchall(cursor)

    def review_data(self):
    # JSON containing data for VariantDisease.vue
        diseases_dict = []
        for association in self.variant.curation_associations.all():
            disease = {}
            disease["disease"] = association.disease.name
            diseases_dict.append(disease)
        return diseases_dict

    #def sib_view_data(self):
    ## JSON containing data for ViewReview.vue


    #def variant_diseases(self):
    ## JSON containing data of dieases associated with current variant, VariantDisease.vue
    #    curations = CurationEntry.objects.filter(variant = self.variant)
    #    diseases_dict = {}
    #    for curation in curations:
    #        disease_id = curation.disease.id
            
    #        if disease_id not in diseases_dict:
    #            disease = {}
    #            disease["disease"] = curation.disease.name
    #            disease["evidences"] = []  
                
    #            for type_of_evidence in ["Prognostic", "Diagnostic", "Predictive / Therapeutic"]:
    #                evidence_type_dict = {}
    #                evidence_type_dict["typeOfEvidence"] = type_of_evidence
    #                evidence_type_dict["isOpen"] = False
    #                evidence_type_dict["curations"] = []
    #                evidence_type_dict["curator"] = {"annotatedEffect": "Unclear", "annotatedTier": "Tier IA: Included in Professional Guidelines"}
    #                evidence_type_dict["note"] = ""
                    
    #                disease["evidences"].append(evidence_type_dict)
                    
    #            diseases_dict[curation.disease.id] = disease
                
    #        #curation_type_of_evidence = curation["type_of_evidence"]
            
    #        for type_of_evidence_dict in diseases_dict[disease_id]["evidences"]:
    #            if type_of_evidence_dict["typeOfEvidence"] == curation.type_of_evidence:
    #                curation_dict = {}
    #                curation_dict["id"] = curation.id
    #                curation_dict["pmid"] = curation.references
    #                curation_dict["comment"] = curation.comment
                    
    #                type_of_evidence_dict["curations"].append(curation_dict)
                
    #    diseases_list = []
    #    for disease_id in diseases_dict:
    #        diseases_list.append(diseases_dict[disease_id])
    #    return diseases_list

    class Meta:
        verbose_name = "Variant in SVIP"
        verbose_name_plural = "Variants in SVIP"


class Review(models.Model):
    reviewer = models.ForeignKey(settings.AUTH_USER_MODEL, null=True, on_delete=models.SET_NULL)
    variant = models.ForeignKey(Variant, on_delete=DB_CASCADE)
    disease = models.ForeignKey(Disease, on_delete=DB_CASCADE)
    type_of_evidence = models.TextField(default="")
    comment = models.TextField(default="")

class SummaryComment(models.Model):
    """
    Summary comment posted by reviewer for a given variant
    """
    content = models.TextField(default="")
    owner = models.ForeignKey(settings.AUTH_USER_MODEL, null=True, on_delete=models.SET_NULL, default=16)
    variant = models.ForeignKey(Variant, on_delete=DB_CASCADE, default=278)
    
    def reviewer(self):
        return f"{self.owner.first_name} {self.owner.last_name}"

# Detects whether a summary comment from same user for same variant already exists, then delete it
@receiver(pre_save, sender=SummaryComment)
def delete_previous(sender, instance, **kwargs):
    # detect if a pk already exists for this Summary comment so you know whether it is a new one being created
    if instance.pk is None:
        print("summary comment is being created")
        same_params = SummaryComment.objects.filter(variant = instance.variant).filter(owner = instance.owner)
        already_a_comment = len(same_params) > 0
        print(f"Already a comment for these params: {already_a_comment}")
        if already_a_comment:
            for summary_com in same_params:
                summary_com.delete()
    else:
        print("summary comment already exists")
    return ""


# ================================================================================================================
# === Disease Aggregation
# ================================================================================================================

class DiseaseInSVIPManager(models.Manager):
    def prune_orphans(self):
        """
        Removes entries that have no derivative data
        :return: the number of removed entries
        """

        return self.get_queryset().filter(
            disease__isnull=False, # we have to preserve null diseases, since they're never explicitly referenced
            sample__isnull=True
        ).exclude(
            disease__in=CurationEntry.objects.values('disease')
        ).delete()

class DiseaseInSVIP(SVIPModel):
    svip_variant = ForeignKey(to=VariantInSVIP, on_delete=DB_CASCADE)
    # a null disease means that the samples or curation entries associated with this variant belong to an
    # unknown or unspecified disease.
    disease = ForeignKey(to=Disease, null=True, on_delete=DB_CASCADE)

    status = models.TextField(default="Loaded")
    score = models.IntegerField(default=0)

    objects = DiseaseInSVIPManager()

    def name(self):
        return self.disease.name if self.disease else "Unspecified"

    class Meta(SVIPModel.Meta):
        verbose_name = "Disease in SVIP"
        verbose_name_plural = "Diseases in SVIP"
        unique_together = ('svip_variant', 'disease')


# ================================================================================================================
# === Curation
# ================================================================================================================


class CurationAssociation(models.Model):
    """
    Associate variant to diseases for which curation was given
    """
    variant = models.ForeignKey(to=Variant, on_delete=DB_CASCADE, related_name="curation_associations")
    disease = models.ForeignKey(to=Disease, on_delete=models.SET_NULL, null=True, blank=True)

class CurationEvidence(models.Model):
    """
    Associate variant to diseases for which curation was given
    """
    association = models.ForeignKey(to=CurationAssociation, on_delete=DB_CASCADE, related_name="curation_evidences")
    type_of_evidence = models.TextField(null=True)
    annotated_effect = models.TextField(default="")
    annotated_tier = models.TextField(default="")
    

CURATION_STATUS = OrderedDict((
    ('draft', 'draft'),
    ('saved', 'saved'),
    ('submitted', 'submitted'),
    ('unreviewed', 'unreviewed'),
    ('reviewed', 'reviewed'),
))


class CurationRequest(SVIPModel):
    """
    Represents a request for a specific variant + disease to be curated.

    These requests are either automatically generated by the system or created by clinicians.
    If the request is created by a clinician, it's considered a higher priority than one that the system generates.
    """

    variant = models.ForeignKey(to=Variant, on_delete=DB_CASCADE)
    disease = ForeignKey(to=Disease, on_delete=DB_CASCADE)

    # there isn't always a requestor, e.g. in the case where it's system-generated or a curator created it themselves
    # if requestor is null, then this is a lower priority than one that was requested by a clinician
    requestor = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=DB_CASCADE, null=True)
    created_on = models.DateTimeField(default=now, db_index=True)
    due_by = models.DateTimeField(db_index=True)

    # TODO: add method that determines the status of the request based on:
    #  1. whether curation entries exist (e.g., someone 'claimed' it)
    #  2. the progress of the reviews
    #  statuses would evolve like so:
    #    -> submitted
    #    -> claimed (curation entry exists)
    #    -> under review (entries submitted for review)
    #    -> finalized (all reviews for all entries completed)


class CurationEntryManager(models.Manager):
    def authed_curation_set(self, user):
        """
        Returns a QuerySet of CurationEntry instances that this user should be able to view
        :param user: the user against which to evaluate CurationEntry permissions
        :return: a QuerySet of CurationEntries visible to the given user
        """
        qset = self.get_queryset()
        result = None

        # qset = (
        #     qset
        #         .select_related('disease', 'variant', 'variant__gene', 'owner')
        #         .prefetch_related('extra_variants')
        # )

        if user.is_authenticated:
            groups = [x.name for x in user.groups.all()]

            if user.is_superuser:
                # superusers can see everything
                result = qset.all()
            if any(x in groups for x in CURATOR_ALLOWED_ROLES):
                # curators see only their own entries if ALLOW_ANY_CURATOR is false
                # if it's true, they can see any curation entry
                result = qset.filter(owner=user) if not ALLOW_ANY_CURATOR else qset.all()
            elif 'reviewers' in groups:
                # FIXME: should reviewers see all entries, or just the ones they've been assigned?
                result = qset.filter(status__in=('reviewed', 'submitted', 'unreviewed'))

        if not result:
            # unauthenticated users and other users who don't have specific roles just see the default set
            result = qset.filter(status__in=PUBLIC_VISIBLE_STATUSES)

        result = (
            result
                .select_related('disease', 'variant', 'variant__gene')
                .prefetch_related('extra_variants')
        )

        return result

class CurationEntry(SVIPModel):
    """
    Represents a curation entry generated by a curator.

    Generally, these are in response to a request, although (apparently?) a curator can create a curation
    entry whenever they want.
    """
    disease = ForeignKey(to=Disease, on_delete=models.SET_NULL, null=True, blank=True)

    # link a curation entry to a curation evidence
    curation_evidences = models.ForeignKey(to=CurationEvidence, related_name="curation_entries", null=True, on_delete=DB_CASCADE)

    # variants = models.ManyToManyField(to=Variant)
    variant = models.ForeignKey(to=Variant, on_delete=DB_CASCADE, related_name="curations")
    extra_variants = models.ManyToManyField(to=Variant, through='VariantCuration', related_name='variants_new')

    type_of_evidence = models.TextField(verbose_name="Type of evidence", null=True)
    drugs = ArrayField(base_field=models.TextField(), verbose_name="Drugs", null=True, blank=True)
    interactions = ArrayField(base_field=models.TextField(), verbose_name="Interactions", null=True, blank=True)
    effect = models.TextField(verbose_name="Effect", null=True)
    tier_level_criteria = models.TextField(verbose_name="Tier level Criteria", null=True)
    tier_level = models.TextField(verbose_name="Tier level", null=True)
    mutation_origin = models.TextField(verbose_name="Mutation Origin", default="Somatic", null=True, blank=True)
    associated_mendelian_diseases = models.TextField(verbose_name="Associated Mendelian Disease(s)", null=True, blank=True)
    summary = models.TextField(verbose_name="Complementary information", null=True, blank=True)
    support = models.TextField(verbose_name="Support", null=True, blank=True)
    comment = models.TextField(verbose_name="Comment", null=True, blank=True)
    references = models.TextField(verbose_name="References", null=True)

    annotations = ArrayField(base_field=models.TextField(), null=True)

    created_on = models.DateTimeField(default=now, db_index=True)
    last_modified = models.DateTimeField(auto_now=True, db_index=True)
    owner = models.ForeignKey(settings.AUTH_USER_MODEL, null=True, on_delete=models.SET_NULL)
    status = models.TextField(verbose_name="Curation Status", choices=tuple(CURATION_STATUS.items()), default='draft', db_index=True)

    # optionally, this curation entry could be the result of "claiming" a curation request
    # FIXME: should we always generate a curation request to make tracking its review easier?
    # FIXME #2: assumedly batches of curation entries are submitted for a single request, so this should be mandatory
    request = ForeignKey(to=CurationRequest, on_delete=DB_CASCADE, null=True, blank=True)

    # FIXME: should we also track the review status's in the entry's history? is that even possible?
    #  it might be: https://django-simple-history.readthedocs.io/en/latest/historical_model.html#adding-additional-fields-to-historical-models
    history = HistoricalRecords(
        excluded_fields=('created_on', 'last_modified'),
        cascade_delete_history=True
    )

    @property
    def icdo_morpho(self):
        if not self.disease:
            return None
        return self.disease.icd_o_morpho

    @property
    def icdo_topo(self):
        if not self.disease:
            return None
        return [x.icd_o_topo for x in self.disease.icdotopoapidisease_set.all()]

    objects = CurationEntryManager()

    def owner_name(self):
        if not self.owner:
            return "N/A"
        fullname = ("%s %s" % (self.owner.first_name, self.owner.last_name)).strip()
        return fullname if fullname else self.owner.username

    def ensure_svip_provenance(self):
        """
        Ensures that a VariantInSVIP exists for the variants/extra variants mentioned
        in this entry, and that a DiseaseInSVIP exists for the variant+disease. This
        includes the case in which the disease is null, in which case an "Unspecified"
        disease is associated with the VariantInSVIP.
        :return: a list of dicts of created objects, [{svip: (entry, created), diseaseinsvip: (entry,created)}, ...]
        """

        created_entries = []

        for variant in chain([self.variant], self.extra_variants.all()):
            # first, see if a SVIPVariant exists
            svip_variant, svip_created = VariantInSVIP.objects.get_or_create(
                variant=variant
            )

            disease_in_svip, disease_created = DiseaseInSVIP.objects.get_or_create(
                svip_variant=svip_variant,
                disease=self.disease
            )

            created_entries.append({
                'variant': variant,
                'svip': (svip_variant, svip_created),
                'diseaseinsvip': (disease_in_svip, disease_created),
            })

        return created_entries

    class Meta:
        verbose_name = "Curation Entry"
        verbose_name_plural = "Curation Entries"


@receiver(pre_save, sender=CurationEntry)
# create an association instance when a curation entry is created (unless already linked to one)
def create_CurationAssociation(sender, instance, **kwargs):
    # detect if a pk already exists for this CurationEntry so you know whether it is a new one being created
    if (instance.pk is None) and (not instance.disease is None):
        associations = CurationAssociation.objects.filter(variant = instance.variant).filter(disease = instance.disease)
        # check that no association already exists for these parameters
        if len(associations) == 0:
            new_curation_association = CurationAssociation(variant = instance.variant, disease = instance.disease)
            new_curation_association.save()
            #instance(curation_evidence = new_curation_association.curation_evidences.get(type_of_evidence = instance.curation_evidence))
    return ""

# create 3 evidence instances when a curation association is created
@receiver(post_save, sender=CurationAssociation)
def create_CurationEvidence(sender, instance, **kwargs):
    for evidence in ["Prognostic", "Diagnostic", "Predictive / Therapeutic"]:
        new_curation_evidence = CurationEvidence(association=instance, type_of_evidence=evidence)
        new_curation_evidence.save()
    return ""


# whenever a curation entry is created, ensure its provenance
@receiver(post_save, sender=CurationEntry, dispatch_uid="update_svip_provenance")
def curation_saved(sender, instance, **kwargs):
    instance.ensure_svip_provenance()

class VariantCuration(SVIPModel):
    """
    Binds curation entries to variants, but with an enforced ordering so we can differentiate the 'main'
    variant from the 'additional' variants. In the future we might also annotate the relationship of the
    variant to the curation entry.`
    """
    variant = models.ForeignKey(Variant, on_delete=DB_CASCADE)
    curationentry = models.ForeignKey(CurationEntry, on_delete=DB_CASCADE)

    class Meta:
        ordering = ('id',)


REVIEW_STATUS = OrderedDict((
    ('pending', 'pending'),
    ('rejected', 'rejected'),
    ('accepted', 'accepted'),
))


class CurationReview(SVIPModel):
    """
    An assignemt of a curation entry to a reviewer. Typically 3 reviewers are selected, each of whom provides a review.

    Once all votes are in:
    - If all three pass, the curation entry is considered 'reviewed' and finalized.
    - If any reject, the curation entry is returned to the 'saved' status(?) for the curator to fix and resubmit or abandon.
    """
    curation_entry = ForeignKey(to=CurationEntry, on_delete=DB_CASCADE)
    reviewer = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=DB_CASCADE)

    created_on = models.DateTimeField(default=now, db_index=True)
    last_modified = models.DateTimeField(auto_now=True, db_index=True)
    status = models.TextField(verbose_name="Review Status", choices=tuple(REVIEW_STATUS.items()), default='pending', db_index=True)


# ================================================================================================================
# === Samples
# ================================================================================================================

class Sample(SVIPModel):
    disease_in_svip = ForeignKey(to=DiseaseInSVIP, on_delete=DB_CASCADE)

    sample_id = models.TextField(verbose_name="Sample ID")
    year_of_birth = models.TextField(verbose_name="Year of birth")
    gender = models.TextField(verbose_name="Gender")
    hospital = models.TextField(verbose_name="Hospital")
    medical_service = models.TextField(verbose_name="Medical service")
    provider_annotation = models.TextField(verbose_name="Provider annotation")
    sample_tissue = models.TextField(verbose_name="Sample Tissue")
    tumor_purity = models.TextField(verbose_name="Tumor purity")
    tnm_stage = models.TextField(verbose_name="TNM stage")
    sample_type = models.TextField(verbose_name="Sample type")
    sample_site = models.TextField(verbose_name="Sample site")
    specimen_type = models.TextField(verbose_name="Specimen Type")
    sequencing_date = models.TextField(verbose_name="Sequencing date")
    panel = models.TextField(verbose_name="Panel")
    coverage = models.TextField(verbose_name="Coverage")
    calling_strategy = models.TextField(verbose_name="Calling strategy")
    caller = models.TextField(verbose_name="Caller")
    aligner = models.TextField(verbose_name="Aligner")
    software = models.TextField(verbose_name="Software")
    software_version = models.TextField(verbose_name="Software version")
    platform = models.TextField(verbose_name="Platform")
    contact = models.TextField(verbose_name="Contact")



## ================================================================================================================
## === Variant Diseases
## ================================================================================================================

#class VariantDiseases(models.Model):
#    #variant = models.OneToOneField(to=Variant, on_delete=DB_CASCADE)
#    random_var = models.TextField(null = True)
    
##    def json_data(self):
##        #curations = CurationEntry.objects.
##        return "test"
