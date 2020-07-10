from collections import OrderedDict
from enum import Enum

from django.contrib.postgres.aggregates import ArrayAgg, JSONBAgg
from django.db import models, ProgrammingError, connection
from django.contrib.postgres.fields import ArrayField, JSONField
from django.db.models import Count, F, Value, Func, Subquery, OuterRef, Q
from django.db.models.base import ModelBase
from django.db.models.functions import Coalesce, Concat

# makes deletes of related objects cascade on the sql server
from django.utils.timezone import now
from django_db_cascade.fields import ForeignKey
from django_db_cascade.deletions import DB_CASCADE

from api.models.genomic import Variant
from api.models.reference import Disease
from api.utils import dictfetchall
from django.conf import settings

from simple_history.models import HistoricalRecords


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

class VariantInSVIP(models.Model):
    """
    Represents SVIP information about a variant. While this could conceivably be handled by VariantInSource,
    it's possible that the SVIP info's structure, operations, and access restrictions will diverge significantly
    from the public data.

    Also, the SVIP-specific data model is still very much a work-in-progress, so I figure it doesn't make sense
    to devote a lot of time to engineering a normalzed data model here. Instead, we just load the contents of the
    mock SVIP variants file into 'data' for each variant.
    """
    variant = ForeignKey(to=Variant, on_delete=DB_CASCADE)
    data = JSONField(default=dict)

    # contains a summary from the curators about this variant
    summary = models.TextField(null=True, blank=True)

    history = HistoricalRecords(cascade_delete_history=True)

    def tissue_counts(self):
        # FIXME: figure out how to do this with the ORM someday
        with connection.cursor() as cursor:
            cursor.execute("""
            select
                Q.sample_tissue as name,
                sum(Q.cnt)::integer as count,
                jsonb_agg(json_build_object('name', Q.disease, 'count', Q.cnt)) as diseases
            from (
              select sample_tissue, ad.name as disease, count(*) as cnt
              from svip_sample sv
              inner join svip_diseaseinsvip d on d.id=sv.disease_in_svip_id
              inner join api_disease ad on ad.id=d.disease_id
              inner join api_variantinsvip av on d.svip_variant_id = av.id
              where svip_variant_id=%s
              group by sample_tissue, disease
            ) as Q
            group by Q.sample_tissue
            """, [self.id])

            return dictfetchall(cursor)

    class Meta:
        verbose_name = "Variant in SVIP"
        verbose_name_plural = "Variants in SVIP"

# ================================================================================================================
# === Disease Aggregation
# ================================================================================================================

class DiseaseInSVIP(SVIPModel):
    svip_variant = ForeignKey(to=VariantInSVIP, on_delete=DB_CASCADE)
    disease = ForeignKey(to=Disease, on_delete=DB_CASCADE)

    status = models.TextField(default="Loaded")
    score = models.IntegerField(default=0)

    def name(self):
        return self.disease.name

    class Meta(SVIPModel.Meta):
        verbose_name = "Disease in SVIP"
        verbose_name_plural = "Diseases in SVIP"


# ================================================================================================================
# === Curation
# ================================================================================================================

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


class CurationEntry(SVIPModel):
    """
    Represents a curation entry generated by a curator.

    Generally, these are in response to a request, although (apparently?) a curator can create a curation
    entry whenever they want.
    """
    disease = ForeignKey(to=Disease, on_delete=DB_CASCADE)

    # variants = models.ManyToManyField(to=Variant)
    variant = models.ForeignKey(to=Variant, on_delete=DB_CASCADE)
    extra_variants = models.ManyToManyField(to=Variant, through='VariantCuration', related_name='variants_new')

    type_of_evidence = models.TextField(verbose_name="Type of evidence", null=True)
    drugs = ArrayField(base_field=models.TextField(), verbose_name="Drugs", null=True, blank=True)
    interactions = ArrayField(base_field=models.TextField(), verbose_name="Interactions", null=True, blank=True)
    effect = models.TextField(verbose_name="Effect", null=True)
    tier_level_criteria = models.TextField(verbose_name="Tier level Criteria", null=True)
    tier_level = models.TextField(verbose_name="Tier level", null=True)
    mutation_origin = models.TextField(verbose_name="Mutation Origin", default="Somatic", null=True)
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
    history = HistoricalRecords(
        excluded_fields=('created_on', 'last_modified'),
        cascade_delete_history=True
    )

    def owner_name(self):
        fullname = ("%s %s" % (self.owner.first_name, self.owner.last_name)).strip()
        return fullname if fullname else self.owner.username

    class Meta:
        verbose_name = "Curation Entry"
        verbose_name_plural = "Curation Entries"


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
