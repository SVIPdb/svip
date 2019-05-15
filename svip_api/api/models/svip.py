from enum import Enum

from django.contrib.postgres.aggregates import ArrayAgg, JSONBAgg
from django.db import models, ProgrammingError, connection
from django.contrib.postgres.fields import ArrayField, JSONField
from django.db.models import Count, F, Value, Func, Subquery, OuterRef
from django.db.models.base import ModelBase
from django.db.models.functions import Coalesce

# makes deletes of related objects cascade on the sql server
from django_db_cascade.fields import ForeignKey
from django_db_cascade.deletions import DB_CASCADE

from api.models.genomic import Variant
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
    data = JSONField()

    def sample_count(self):
        return self.sample_set.count()

    def sample_diseases_count(self):
        return (
            self.sample_set
                .values(name=F('disease'))
                .annotate(count=Count('disease'))
                .distinct().order_by('-count')
        )

    def tissue_counts(self):
        # FIXME: figure out how to do this with the ORM someday
        with connection.cursor() as cursor:
            cursor.execute("""
            select
                Q.sample_tissue as name,
                sum(Q.cnt)::integer as count,
                jsonb_agg(json_build_object('name', Q.disease, 'count', Q.cnt)) as diseases
            from (
              select sample_tissue, disease, count(*) as cnt
              FROM "svip_sample"
              where svip_variant_id=%s
              group by sample_tissue, disease
            ) as Q
            group by Q.sample_tissue
            """, [self.id])

            return dictfetchall(cursor)


class CurationEntry(SVIPModel):
    svip_variant = ForeignKey(to=VariantInSVIP, on_delete=DB_CASCADE)

    disease = models.TextField(verbose_name="Disease")
    type_of_evidence = models.TextField(verbose_name="Type of evidence")
    drug = models.TextField(verbose_name="Drug")
    effect = models.TextField(verbose_name="Effect")
    tier_level_criteria = models.TextField(verbose_name="Tier level Criteria")
    summary = models.TextField(verbose_name="Summary")
    support = models.TextField(verbose_name="Support")
    references = models.TextField(verbose_name="References")


class Sample(SVIPModel):
    svip_variant = ForeignKey(to=VariantInSVIP, on_delete=DB_CASCADE)

    disease = models.TextField(verbose_name="Disease")
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
