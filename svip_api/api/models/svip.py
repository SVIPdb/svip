from collections import OrderedDict
from datetime import datetime
from enum import Enum
from io import StringIO
from itertools import chain

from django.conf import settings
from django.contrib.postgres.fields import ArrayField, JSONField
from django.db import connection, models
from django.db.models.base import ModelBase
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.utils.timezone import now
from django_db_cascade.deletions import DB_CASCADE
from django_db_cascade.fields import ForeignKey
from simple_history.models import HistoricalRecords

from api.models.genomic import Variant, Gene
from api.models.reference import Disease
from api.permissions import (ALLOW_ANY_CURATOR, CURATOR_ALLOWED_ROLES,
                             PUBLIC_VISIBLE_STATUSES)
from api.utils import dictfetchall, ModelChoice


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

    # status = models.TextField(null=True, blank=True)

    variant = models.OneToOneField(
        to=Variant, on_delete=DB_CASCADE, related_name="variantinsvip")
    # variant = models.OneToOneField(to=Variant, on_delete=DB_CASCADE)
    data = JSONField(default=dict)
    # contains a summary from the curators about this variant
    summary = models.TextField(null=True, blank=True)
    summary_date = models.DateTimeField(null=True)
    objects = VariantInSVIPManager()
    history = HistoricalRecords(cascade_delete_history=True)

    def calculate_summary_date(self):
        if self.summary_date:
            return self.summary_date

        else:
            if not self.summary:
                return None

            if len(self.history.all()) == 1:
                return self.history.last().history_date

            if len(self.history.all()) > 1:
                current = self.history.first()
                for i in range(1, len(self.history.all())):
                    version = self.history.all()[i]
                    delta = current.diff_against(version)
                    for change in delta.changes:
                        if change.field == 'summary':
                            return self.history.all()[i - 1].history_date
            return None

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

    class Meta:
        verbose_name = "Variant in SVIP"
        verbose_name_plural = "Variants in SVIP"


class SummaryDraft(models.Model):
    """
    Uncompleted summary specific to a curator and a given variant
    """
    content = models.TextField(default="")
    owner = models.ForeignKey(settings.AUTH_USER_MODEL,
                              null=True, on_delete=models.SET_NULL)
    variant = models.ForeignKey(Variant, on_delete=DB_CASCADE)


class SummaryComment(models.Model):
    """
    Summary comment posted by reviewer for a given variant
    """
    content = models.TextField(default="")
    owner = models.ForeignKey(settings.AUTH_USER_MODEL,
                              null=True, on_delete=models.SET_NULL)
    variant = models.ForeignKey(Variant, on_delete=DB_CASCADE)

    def reviewer(self):
        return f"{self.owner.first_name} {self.owner.last_name}"


class GeneSummaryDraft(models.Model):
    """
    Uncompleted summary specific to a curator and a given gene
    """
    content = models.TextField(default="")
    owner = models.ForeignKey(settings.AUTH_USER_MODEL,
                              null=True, on_delete=models.SET_NULL)
    gene = models.ForeignKey(Gene, on_delete=DB_CASCADE)


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
            # we have to preserve null diseases, since they're never explicitly referenced
            disease__isnull=False,
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
        # unique_together = ('svip_variant', 'disease')


# ================================================================================================================
# === Curation
# ================================================================================================================


class SubmissionEntry(models.Model):
    """
    The entry that is being annotated and submitted: a unique combination of
    variant, disease, type of evidence, and drug (if present).
    This combination is annotated by a curator based on one or more curation entries.
    The entry is generated from all the curation entries of a variant at the moment of their submission.
    """
    related_name = 'submission_entries'
    variant = models.ForeignKey(Variant, on_delete=DB_CASCADE, related_name=related_name)
    owner = models.ForeignKey(settings.AUTH_USER_MODEL,
                              null=True, on_delete=models.SET_NULL)

    disease = models.ForeignKey(
        to=Disease, on_delete=models.SET_NULL, null=True, blank=True)
    type_of_evidence = models.TextField(
        verbose_name="Type of evidence")
    drug = models.TextField(null=True)
    effect = models.TextField(default="Not yet annotated")
    tier = models.TextField(default="Not yet annotated")
    review_cycle = models.IntegerField(default=1)


class CURATION_STATUS(ModelChoice):
    draft = 'draft'
    saved = 'saved'
    ready_for_submission = 'ready_for_submission'
    submitted = 'submitted'
    unreviewed = 'unreviewed'
    reviewed = 'reviewed'


class REVIEW_STATUS(ModelChoice):
    pending = 'pending'
    rejected = 'rejected'
    accepted = 'accepted'


class CurationRequest(SVIPModel):
    """
    Represents a request for a specific variant + disease to be curated.

    These requests are either automatically generated by the system or created by clinicians.
    If the request is created by a clinician, it's considered a higher priority than one that the system generates.
    """
    submission = models.ForeignKey(
        'SubmittedVariant', on_delete=models.SET_NULL, null=True)
    variant = models.ForeignKey(
        to=Variant, on_delete=models.SET_NULL, null=True, related_name='curation_request')
    disease = ForeignKey(to=Disease, on_delete=DB_CASCADE)

    # there isn't always a requestor, e.g. in the case where it's system-generated or a curator created it themselves
    # if requestor is null, then this is a lower priority than one that was requested by a clinician
    requestor = models.TextField(null=True)
    created_on = models.DateTimeField(default=now, db_index=True)
    due_by = models.DateTimeField(db_index=True, null=True)

    # TODO: add method that determines the status of the request based on:
    #  1. whether curation entries exist (e.g., someone 'claimed' it)
    #  2. the progress of the reviews
    #  statuses would evolve like so:
    #    -> submitted
    #    -> claimed (curation entry exists)
    #    -> under review (entries submitted for review)
    #    -> finalized (all reviews for all entries completed)

    class Meta:
        unique_together = ('submission', 'variant')


class CurationEntryManager(models.Manager):
    evidence_type_category_lookup = {
        'diagnostic': ["Prognostic", "Diagnostic", "Predictive / Therapeutic"]}

    def get_by_evidence_type_category(self, category):
        qset = self.get_queryset()
        return qset.filter(type_of_evidence__in=self.evidence_type_category_lookup[category])

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
                result = qset.filter(
                    owner=user) if not ALLOW_ANY_CURATOR else qset.all()
            elif 'reviewers' in groups:
                # FIXME: should reviewers see all entries, or just the ones they've been assigned?
                result = qset.filter(status__in=(
                    'reviewed', 'submitted', 'unreviewed'))

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
    related_name = 'curation_entries'
    submission_entry = ForeignKey(to=SubmissionEntry, on_delete=models.SET_NULL, null=True)
    disease = ForeignKey(
        to=Disease, on_delete=models.SET_NULL, null=True, blank=True)

    variant = models.ForeignKey(
        to=Variant, on_delete=DB_CASCADE, related_name=related_name)
    extra_variants = models.ManyToManyField(
        to=Variant, through='VariantCuration', related_name='variants_new')

    type_of_evidence = models.TextField(
        verbose_name="Type of evidence", null=True)
    drugs = ArrayField(base_field=models.TextField(),
                       verbose_name="Drugs", null=True, blank=True)
    interactions = ArrayField(base_field=models.TextField(
    ), verbose_name="Interactions", null=True, blank=True)
    effect = models.TextField(verbose_name="Effect", null=True)
    tier_level_criteria = models.TextField(
        verbose_name="Tier level Criteria", null=True)
    tier_level = models.TextField(verbose_name="Tier level", null=True)
    mutation_origin = models.TextField(
        verbose_name="Mutation Origin", default="Somatic", null=True, blank=True)
    associated_mendelian_diseases = models.TextField(
        verbose_name="Associated Mendelian Disease(s)", null=True, blank=True)
    summary = models.TextField(
        verbose_name="Complementary information", null=True, blank=True)
    support = models.TextField(verbose_name="Support", null=True, blank=True)
    comment = models.TextField(verbose_name="Comment", null=True, blank=True)
    references = models.TextField(verbose_name="References", null=True)

    annotations = ArrayField(
        base_field=models.TextField(), null=True, blank=True)

    created_on = models.DateTimeField(default=now, db_index=True)
    last_modified = models.DateTimeField(auto_now=True, db_index=True)
    owner = models.ForeignKey(settings.AUTH_USER_MODEL,
                              null=True, on_delete=models.SET_NULL)
    status = models.TextField(verbose_name="Curation Status", choices=CURATION_STATUS.get_choices(), default='draft',
                              db_index=True)

    escat_score = models.TextField(
        verbose_name="ESCAT score", null=True, blank=True)

    # optionally, this curation entry could be the result of "claiming" a curation request
    # FIXME: should we always generate a curation request to make tracking its review easier?
    # FIXME #2: assumedly batches of curation entries are submitted for a single request, so this should be mandatory
    request = ForeignKey(to=CurationRequest,
                         on_delete=DB_CASCADE, null=True, blank=True)

    history = HistoricalRecords(
        excluded_fields=('created_on', 'last_modified'),
        cascade_delete_history=True
    )

    @property
    def review_status(self):
        """
            Returns the consolidated revew status of this particular curation entriy
        """
        review_count = self.curation_reviews.count()
        acceped_review_count = self.curation_reviews.by_status(REVIEW_STATUS.accepted).count()
        if review_count == Variant.MIN_ACCEPTED_REVIEW_COUNT and acceped_review_count < Variant.MIN_ACCEPTED_REVIEW_COUNT:
            return REVIEW_STATUS.rejected
        elif acceped_review_count >= Variant.MIN_ACCEPTED_REVIEW_COUNT:
            return REVIEW_STATUS.accepted
        else:
            return REVIEW_STATUS.pending

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

    def short_escat_score(self):
        if self.escat_score == None:
            return 'Unavailable'
        else:
            return self.escat_score.split(':')[0]

    def owner_name(self):

        if not self.owner:
            return "N/A"
        fullname = ("%s %s" % (self.owner.first_name,
                               self.owner.last_name)).strip()
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


class CurationReview(SVIPModel):
    """
    An assignemt of a curation entry to a reviewer. Typically 3 reviewers are selected, each of whom provides a review.

    Once all votes are in:
    - If all three pass, the curation entry is considered 'reviewed' and finalized.
    - If any reject, the curation entry is returned to the 'saved' status(?) for the curator to fix and resubmit or abandon.
    """
    related_name = 'curation_reviews'
    submission_entry = models.ForeignKey(to=SubmissionEntry, on_delete=DB_CASCADE, related_name=related_name, null=True)
    reviewer = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=DB_CASCADE, related_name=related_name, null=True)

    created_on = models.DateTimeField(default=now, db_index=True)
    last_modified = models.DateTimeField(auto_now=True, db_index=True)
    acceptance = models.BooleanField(default=True)

    annotated_effect = models.TextField(null=True, blank=True)
    annotated_tier = models.TextField(null=True, blank=True)
    comment = models.TextField(default="", null=True, blank=True)

    draft = models.BooleanField(default=False)

    def match(self):
        submission_entry = self.submission_entry
        return (self.annotated_effect == submission_entry.effect) and (self.annotated_tier == submission_entry.tier)


# ================================================================================================================
# === SVIP Variant Submission
# ================================================================================================================

class SubmittedVariantBatch(SVIPModel):
    """
    A batch of variant descriptions (i.e., SubmittedVariants) submitted for addition into SVIP.
    Typically these batches of variants will be uploaded as a VCF.
    """

    owner = models.ForeignKey(settings.AUTH_USER_MODEL,
                              on_delete=models.SET_NULL, null=True)
    created_on = models.DateTimeField(default=now, db_index=True)

    vcf_body = models.TextField()

    def owner_name(self):
        if not self.owner:
            return "N/A"
        fullname = ("%s %s" % (self.owner.first_name,
                               self.owner.last_name)).strip()
        return fullname if fullname else self.owner.username


class SubmittedVariantManager(models.Manager):
    VCF_HEADER_TEMPLATE = """##fileformat=VCFv4.0
    ##fileDate=%(curdate)s
    ##source=svip_queue
    #CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO
    """

    def as_vcf(self, as_str=False):
        """
        For the given queryset, produces a bare-bones VCF representation.

        as_str: if true, returns a string rather than a file handle
        """

        fp = StringIO()
        fp.write(SubmittedVariantManager.VCF_HEADER_TEMPLATE % {
            'curdate': datetime.now().strftime("%Y%m%d")
        })
        fp.writelines(rec.as_vcf_row() for rec in self.get_queryset())

        if as_str:
            result = fp.getvalue()
            fp.close()
            return result
        else:
            fp.seek(0)
            return fp


class SubmittedVariant(SVIPModel):
    """
    A description of a variant that, once processed by the SVIP harvester,
    will become a variant. The metadata for that variant will be retrieved
    via VEP.
    """

    SUBMITTED_VAR_STATUS = OrderedDict((
        ('pending', 'pending'),
        ('completed', 'completed'),
        ('error', 'error'),
    ))
    SUBMITTED_VAR_CHROMOSOME = tuple(
        (x, x) for x in list(range(1, 23)) + ["X", "Y", "MT"])

    owner = models.ForeignKey(settings.AUTH_USER_MODEL,
                              on_delete=models.SET_NULL, null=True)
    created_on = models.DateTimeField(default=now, db_index=True)

    chromosome = models.TextField(choices=SUBMITTED_VAR_CHROMOSOME)
    pos = models.IntegerField()
    ref = models.TextField()
    alt = models.TextField()

    canonical_only = models.BooleanField(
        default=False, help_text='If true, only retain VEP variants marked canonical')

    # an optional batch from which this variant originates
    batch = ForeignKey(SubmittedVariantBatch,
                       on_delete=models.SET_NULL, null=True)

    status = models.TextField(verbose_name="Processing Status", choices=tuple(
        SUBMITTED_VAR_STATUS.items()), default='pending', db_index=True)
    processed_on = models.DateTimeField(db_index=True, null=True)
    error_msg = models.TextField(null=True)

    # the set of variants that were harvested from VEP for this submission
    # (there can be more than one, since VEP can return multiple results for a single chrom/pos/ref/alt set)
    resulting_variants = ArrayField(
        base_field=models.IntegerField(), null=True)

    for_curation_request = models.BooleanField(default=False,
                                               help_text='If true, a curation request should be created when this submission is completed')
    curation_disease = models.ForeignKey(Disease, on_delete=models.SET_NULL, null=True,
                                         help_text='If for_curation_request is true, identifies the disease to which the new curation request should be associated')
    requestor = models.TextField(
        blank=True, null=True,
        help_text='If for_curation_request is true, identifies who asked for this variant to be submitted')

    objects = SubmittedVariantManager()

    @property
    def icdo_morpho(self):
        if not self.curation_disease:
            return None
        return self.curation_disease.icd_o_morpho

    @property
    def icdo_topo(self):
        if not self.curation_disease:
            return None
        return [x.icd_o_topo for x in self.curation_disease.icdotopoapidisease_set.all()]

    def owner_name(self):
        if not self.owner:
            return "N/A"
        fullname = ("%s %s" % (self.owner.first_name,
                               self.owner.last_name)).strip()
        return fullname if fullname else self.owner.username

    def as_vcf_row(self):
        # CHROM  POS  ID  REF  ALT  QUAL  FILTER  INFO
        # QUAL and INFO are both '.', which indicates an empty field(?)
        original_alt = ",".join(
            [x.strip() for x in self.alt.strip("[]").replace("None", ".").split(",")])
        return "\t".join(
            str(x) for x in [self.chromosome, self.pos, self.id, self.ref, original_alt, '.', 'PASS', '.']) + "\n"


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
