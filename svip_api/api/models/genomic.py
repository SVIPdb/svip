import itertools

from collections import OrderedDict
from django.contrib.postgres.fields import ArrayField, JSONField
from django.contrib.postgres.fields.jsonb import KeyTextTransform
from django.db import models, connection
from django.db.models import Count, F, Value, Func, Sum, IntegerField
from django.db.models.functions import Coalesce, Cast
from django_db_cascade.deletions import DB_CASCADE
# makes deletes of related objects cascade on the sql server
from django_db_cascade.fields import ForeignKey

from api.utils import dictfetchall

# types of evidence, which influence the contents of the evidence structure
# see https://civicdb.org/help/evidence/evidence-types for details
# the format below is (actual value, human readable name) tupes
EVIDENCE_TYPES = [
    ('predictive', 'Predictive'),
    ('prognostic', 'Prognostic'),
    ('predisposing', 'Predisposing'),
    ('diagnostic', 'Diagnostic'),
]


class Source(models.Model):
    # FIXME: some parts of the system still use text strings to identify sources, but they should use this table
    name = models.TextField(null=False, unique=True, db_index=True)
    display_name = models.TextField(null=False)

    no_associations = models.BooleanField(default=False,
        help_text="Indicates that this source doesn't contain evidence. If true, filters this source out from variantinsource queries")

    def num_variants(self):
        return VariantInSource.objects.filter(source=self).count()

    def __str__(self):
        return "%s (%s, id: %s)" % (self.display_name, self.name, self.id)

class GeneManager(models.Manager):
    def get_by_natural_key(self, symbol):
        return self.get(symbol=symbol)

class Gene(models.Model):
    entrez_id = models.BigIntegerField(unique=True, db_index=True)
    ensembl_gene_id = models.TextField(db_index=True)
    symbol = models.TextField(unique=True, db_index=True)
    uniprot_ids = ArrayField(base_field=models.TextField(), null=True, verbose_name="UniProt IDs")
    location = models.TextField(null=True)

    # this object is used as a set; to add an entry: sources = jsonb_set(sources, '{newfield}', null, TRUE)
    sources = ArrayField(base_field=models.TextField(), null=True, verbose_name="Sources")

    aliases = ArrayField(base_field=models.TextField(), default=list, null=True)
    prev_symbols = ArrayField(base_field=models.TextField(), default=list, null=True)

    # sources = ArrayField(
    #     base_field=ForeignKey(to=Source, to_field='name', on_delete=DB_CASCADE), default=list)

    objects = GeneManager()

    def natural_key(self):
        return (self.symbol,)

    def __str__(self):
        return "%s (entrez id: %d)" % (self.symbol, self.entrez_id)


class VariantManager(models.Manager):
    def get_by_natural_key(self, description, hgvs_g):
        return self.get(description=description, hgvs_g=hgvs_g)
    
    

class Variant(models.Model):
    gene = ForeignKey(to=Gene, on_delete=DB_CASCADE)

    name = models.TextField(null=False, db_index=True, verbose_name="Variant Name")
    description = models.TextField(null=True, db_index=True)

    biomarker_type = models.TextField(null=True)
    so_hierarchy = ArrayField(base_field=models.CharField(max_length=15), null=True, verbose_name="Hierarchy of SO IDs")
    soid = models.TextField(null=True, verbose_name="Sequence Ontology ID", default="")
    so_name = models.TextField(null=True, db_index=True)

    reference_name = models.TextField(null=True)  # e.g., GRCh37
    refseq = models.TextField(null=True)  # an NCBI refseq id
    isoform = models.TextField(null=True)  # not clear, but typically an ensembl transcript accession ID

    # position and change data
    chromosome = models.CharField(max_length=10, null=True)
    start_pos = models.IntegerField(null=True)
    end_pos = models.IntegerField(null=True)
    ref = models.TextField(null=True)
    alt = models.TextField(null=True)

    hgvs_g = models.TextField(null=True, db_index=True)
    hgvs_c = models.TextField(null=True, db_index=True)
    hgvs_p = models.TextField(null=True, db_index=True)

    somatic_status = models.TextField(null=True)

    # external references
    dbsnp_ids = ArrayField(base_field=models.TextField(), null=True, verbose_name="UniProt IDs")
    myvariant_hg19 = models.TextField(null=True, verbose_name="=MyVariant.info URL (hg19)")
    mv_info = JSONField(null=True)  # optional info pulled from myvariant.info; see normalizers.myvariant_enricher

    # we should be able to compute this from api_source
    sources = ArrayField(base_field=models.TextField(), null=True, verbose_name="Sources")

    # stores errors, exceptions encountered while crawling
    crawl_status = JSONField(null=True)

    objects = VariantManager()

    def __str__(self):
        # return "%s %s" % (self.gene.symbol, self.name)
        return self.description

    def gene_symbol(self):
        return self.gene.symbol

    def in_svip(self):
        return hasattr(self, 'variantinsvip') and self.variantinsvip is not None

    def natural_key(self):
        return self.description, self.hgvs_g

    class Meta:
        indexes = [
            models.Index(fields=['gene', 'name']),
            models.Index(fields=['gene', 'name', 'hgvs_c']),
        ]
    
    @property
    def stage(self):

        if self.curation_associations.count() > 0:
            if self.curation_associations.first().curation_evidences.count() > 0:
                evidence = self.curation_associations.first().curation_evidences.first()

                if evidence.revised_reviews.all().count() == 3:
                    if evidence.revised_reviews.filter(agree=True).count() == 3:
                        return 'fully_reviewed'
                    else:
                        return 'on_hold'

                if hasattr(evidence, 'annotation2'):
                    return 'to_review_again'

                if evidence.reviews.count() == 3:
                    if hasattr(evidence, 'annotation1'):
                        if evidence.reviews.filter(
                            annotated_effect=self.annotation1.effect,
                            annotated_tier=self.annotation1.tier
                        ).count() == 3:
                            return 'fully_reviewed'
                        else:
                            return 'conflicting_reviews'

                if evidence.reviews.count() == 2:
                    return '2_reviews'

                if evidence.reviews.count() == 1:
                    return '1_review'

        for curation in self.curations.all():
            if curation.status == 'submitted':
                return '0_review'

        if self.curations.all().count() > 0 :
            return 'ongoing_curation'

        if self.curation_request.all().count() > 0:
            return 'loaded'

        return 'none'

    @property
    def public_stage(self):
        stage = self.stage
        if stage in ['none']:
            return 'None'
        elif stage in ['loaded']:
            return 'Loaded'
        elif stage in ['ongoing_curation']:
            return 'In progress'
        elif stage in ['0_review', '1_review', '2_reviews', 'conflicting_reviews', 'to_review_again']:
            return 'Annotated'
        elif stage in ['on_hold']:
            return 'On hold'
        elif stage in ['fully_reviewed']:
            return 'Approved'

    @property
    def confidence(self):
        confidence_dict = {
            'None': 0,
            'Loaded': 1,
            'In progress': 1,
            'Annotated': 2,
            'On hold': 2,
            'Approved': 3
        }
        return confidence_dict[self.public_stage]

class VariantInSource(models.Model):
    """
    Represents the entry that a specific source (say, CIViC) has for a variant. This includes source-specific variant-
    level information, such as the link to the variant in that source.
    """

    variant = ForeignKey(to=Variant, on_delete=DB_CASCADE, db_index=True)
    source = ForeignKey(to=Source, on_delete=DB_CASCADE, db_index=True)

    variant_url = models.TextField(null=True, verbose_name="Variant's URL for this source")
    # this holds source-specific values like COSMIC's variant-level FATHMM predictions/scores
    extras = JSONField(null=True, verbose_name="Source-specific extra data")

    class Meta:
        unique_together = (("variant", "source"),)

    # TODO: add link to variant in that source (i.e, move it from Association to here)

    # TODO: add aggregations that the front-end is currently computing on its own, specifically:
    #  diseases: [],
    #  database_evidences: [], (this is actually just used to count the number of evidence items)
    #    (review val h.'s request to count the number of evidence item PMIDs, not sure it makes sense)
    #  clinical: [], (this is actually the association object, but it does a lot of client-side stuff, so we won't replicate it here)
    #  scores: []

    def association_count(self):
        return self.association_set.count()

    def publication_count(self, is_distinct=False):
        q = (
            self.association_set
                .annotate(q=Func(F('evidence__publications'), function='unnest'))
                .values_list('q', flat=True)
        )
        return q.count() if not is_distinct else q.distinct().count()

    def diseases(self):
        # FIXME: this sucks, but clinvar right now is pre-aggregated by disease, so we need another
        #  way to surface the real submission count (which is held in extras.num_submissions)

        # this is used to render the 'disease' filtering side tables in the third-party evidence panel
        if self.source.name == 'clinvar':
            return (
                self.association_set
                    .values(disease=F('phenotype__term'))
                    .annotate(count=Sum(Cast(KeyTextTransform('num_submissions', 'extras'), IntegerField())))
                    .distinct().order_by('-count')
            )

        return (
            self.association_set
                .values(disease=F('phenotype__term'))
                .annotate(count=Count('phenotype__term'))
                .distinct().order_by('-count')
        )

    def diseases_collapsed(self):
        # this is used to render the 'disease' filtering side tables in specifically civic's third-party evidence panel
        # (or whichever third-party evidence lists use collapsed associations rather than normal ones)
        return (
            self.collapsedassociation_set
                .values('disease')
                .annotate(count=Count('disease'))
                .distinct().order_by('-count')
        )

    def contexts(self):
        # this is used to render the 'tissues' filtering side tables in specifically cosmic's third-party evidence panel
        return (
            self.association_set
                .values(context=F('environmentalcontext__description'))
                .exclude(context__isnull=True)
                .annotate(count=Count('environmentalcontext__description'))
                .distinct().order_by('-count')
        )

    def diseases_contexts(self):
        # this is used to render the 'diseases/tissues' visualization on the variant details page
        pairs = (
            self.association_set
                .values(disease=F('phenotype__term'), context=F('environmentalcontext__description'))
                .exclude(disease__isnull=True, context__isnull=True)
                .annotate(count=Count('environmentalcontext__description'))
                .distinct().order_by('disease')
        )
        return (
            {x[0]: {y['context']: y['count'] for y in x[1]}}
            for x in itertools.groupby(pairs, lambda x: x['disease'])
        )

    def clinical_significances(self):
        return (
            self.association_set
                .values(name=Coalesce('clinical_significance', Value('N/A')))
                .annotate(count=Count(Coalesce('clinical_significance', Value('N/A'))))
                .distinct().order_by('-count')
        )

    def evidence_types(self):
        # return (
        #     self.association_set
        #         .values(name=F('evidence_type'))
        #         .annotate(count=Count('evidence_type'))
        #         .distinct().order_by('-count')
        # )

        with connection.cursor() as cursor:
            cursor.execute("""
            select
                aa.evidence_type as name, count(*) as count,
                case when evidence_type='Predisposing' or evidence_type='Functional' then
                array(
                    select row_to_json(r.*) from (
                        select as_in.clinical_significance as name, count(*) as count
                        from api_association as_in
                        where as_in.id=any(array_agg(aa.id))
                        group by as_in.clinical_significance
                    ) r
                 )
                END as subsigs
            from api_variantinsource vis
            inner join api_variant av on vis.variant_id = av.id
            inner join api_association aa on vis.id = aa.variant_in_source_id
            where vis.id=%s
            group by aa.evidence_type;
            """, [self.id])

            return dictfetchall(cursor)

    def scores(self):
        return dict(
            self.association_set
                .values(score=Coalesce('evidence_level', Value('n/a')))
                .annotate(count=Count(Coalesce('evidence_level', Value('n/a'))))
                .distinct().values_list('score', 'count')
        )


class Association(models.Model):
    """
    Represents the connection between a Variant and its Phenotypes, Evidences, and EnvironmentalContexts for a specific
    source. There is one Association per pairing of variant, (sets of) phenotypes, and (sets of) contexts.
    """
    variant_in_source = ForeignKey(to=VariantInSource, on_delete=DB_CASCADE, null=False)

    # FIXME: move this to VariantInSource
    source_url = models.TextField(null=True, verbose_name="URL of the variant's entry in the source")
    source = models.TextField()

    # temporary field to log exactly what we're getting from the server
    payload = JSONField(default=dict)

    description = models.TextField(null=True)
    drug_labels = models.TextField(null=True)
    drug_interaction_type = models.TextField(null=True)

    variant_name = models.TextField(null=True)  # here for debugging, remove if it's always the name as Variant__name
    source_link = models.TextField(null=True, verbose_name="URL of the association's entry in the source")

    # these are modeled after CIViC, with the other sources' ratings shoehorned into these fields
    evidence_type = models.TextField(null=True, choices=EVIDENCE_TYPES)
    evidence_direction = models.TextField(null=True)
    clinical_significance = models.TextField(null=True)
    evidence_level = models.TextField(null=True)

    # stores errors, exceptions encountered while crawling
    crawl_status = JSONField(null=True)
    # stores extra data that doesn't fit into the association structure
    extras = JSONField(null=True, verbose_name="Association-specific extra data")


class CollapsedAssociation(models.Model):
    """
    A simplified version of Association that collapses entries that have the same information except the source
    evidence ID and the list of publications, to circumvent denormalized entries in public databases.

    For example, CIViC has three entries for (BRAF, V600E, Cholangiocarcinoma) that only differ by the publications
    associated with the submission. They should instead be a single entry with three publications.

    Additionally, this model presents a schema that's closer to what the front-end expects, removing the need to
    transform and/or aggregate fields in the client (e.g., the contexts field, which is a concatenation of all the
    EnvironmentalContext.description values for this Association).
    """
    variant_in_source = ForeignKey(to=VariantInSource, null=False, on_delete=models.DO_NOTHING)

    disease = models.TextField(blank=True, null=True)
    evidence_type = models.TextField(blank=True, null=True)
    evidence_direction = models.TextField(blank=True, null=True)
    clinical_significance = models.TextField(blank=True, null=True)
    drug_labels = models.TextField(blank=True, null=True)
    contexts = models.TextField(blank=True, null=True)
    evidence_levels = models.TextField(blank=True, null=True)
    publications = ArrayField(base_field=models.TextField(), blank=True, null=True, verbose_name="Publication URLs")
    children = JSONField(blank=True, null=True)
    collapsed_count = models.BigIntegerField(blank=True, null=True)

    class Meta:
        managed = False  # Created from a view. Don't remove.
        db_table = 'api_collapsed_associations'


# all of the following are optional children of Association

class Phenotype(models.Model):
    association = ForeignKey(to=Association, on_delete=DB_CASCADE)

    source = models.TextField(null=True)
    term = models.TextField(null=True)
    pheno_id = models.TextField(null=True)  # just called 'id' in the original object
    family = models.TextField(null=True)
    description = models.TextField(null=True)


class Evidence(models.Model):
    association = ForeignKey(to=Association, on_delete=DB_CASCADE)

    # originally under association.evidence[].info.publications[]
    publications = ArrayField(base_field=models.TextField(), null=True, verbose_name="Publication URLs")

    # originally under association.evidence[].evidenceType.sourceName
    evidenceType_sourceName = models.TextField(null=True)
    # originally under association.evidence[].evidenceType.id
    evidenceType_id = models.TextField(null=True)


class EnvironmentalContext(models.Model):
    association = ForeignKey(to=Association, on_delete=DB_CASCADE)

    source = models.TextField(null=True)
    term = models.TextField(null=True)
    envcontext_id = models.TextField(null=True)  # just called 'id' in the original object
    usan_stem = models.TextField(null=True)
    description = models.TextField()
