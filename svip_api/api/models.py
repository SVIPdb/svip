from django.db import models
from django.contrib.postgres.fields import ArrayField, JSONField


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

    def __str__(self):
        return "%s (%s, id: %s)" % (self.display_name, self.name, self.id)


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
    #     base_field=models.ForeignKey(to=Source, to_field='name', on_delete=models.CASCADE), default=list)

    def __str__(self):
        return "%s (entrez id: %d)" % (self.symbol, self.entrez_id)


class Variant(models.Model):
    gene = models.ForeignKey(to=Gene, on_delete=models.CASCADE)

    name = models.TextField(null=False, db_index=True, verbose_name="Variant Name")
    description = models.TextField(null=True, db_index=True)

    biomarker_type = models.TextField(null=True)
    so_hierarchy = ArrayField(base_field=models.CharField(max_length=15), null=True, verbose_name="Hierarchy of SO IDs")
    soid = models.TextField(null=True, verbose_name="Sequence Ontology ID", default="")
    so_name = models.TextField(null=True)

    reference_name = models.TextField(null=True)  # e.g., GRCh37
    refseq = models.TextField(null=True)
    isoform = models.TextField(null=True)

    # position and change data
    chromosome = models.CharField(max_length=10, null=True)
    start_pos = models.IntegerField(null=True)
    end_pos = models.IntegerField(null=True)
    ref = models.TextField(null=True)
    alt = models.TextField(null=True)

    hgvs_g = models.TextField(null=True)
    hgvs_c = models.TextField(null=True)
    hgvs_p = models.TextField(null=True)

    # external references
    dbsnp_ids = ArrayField(base_field=models.TextField(), null=True, verbose_name="UniProt IDs")
    myvariant_hg19 = models.TextField(null=True, verbose_name="=MyVariant.info URL (hg19)")
    mv_info = JSONField(null=True)  # optional info pulled from myvariant.info; see normalizers.myvariant_enricher

    # we should be able to compute this from
    sources = ArrayField(base_field=models.TextField(), null=True, verbose_name="Sources")

    def __str__(self):
        return "%s %s" % (self.gene.symbol, self.name)

    def gene_symbol(self):
        return self.gene.symbol

    class Meta:
        indexes = [
            models.Index(fields=['gene', 'name'])
        ]


class VariantInSource(models.Model):
    """
    Represents the entry that a specific source (say, CIViC) has for a variant. This includes source-specific variant-
    level information, such as the link to the variant in that source.
    """

    variant = models.ForeignKey(to=Variant, on_delete=models.CASCADE, db_index=True)
    source = models.ForeignKey(to=Source, on_delete=models.CASCADE, db_index=True)

    variant_url = models.TextField(null=True, verbose_name="Variant's URL for this source")
    # this holds source-specific values like COSMIC's variant-level FATHMM predictions/scores
    extras = JSONField(null=True, verbose_name="Source-specific extra data")

    class Meta:
        unique_together = (("variant", "source"),)

    # TODO: add link to variant in that source (i.e, move it from Association to here)

    # TODO: add aggregations that the front-end is currently computing on its own, specifically:
    #  diseases: [],
    #  database_evidences: [],
    #  clinical: [],
    #  scores: []


class Association(models.Model):
    """
    Represents the connection between a Variant and its Phenotypes, Evidences, and EnvironmentalContexts for a specific
    source. There is one Association per pairing of variant, (sets of) phenotypes, and (sets of) contexts.
    """
    variant_in_source = models.ForeignKey(to=VariantInSource, on_delete=models.CASCADE, null=False)

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

    # TODO: current evidence label, level, etc. to be replaced
    evidence_type = models.TextField(null=True, choices=EVIDENCE_TYPES)  # FIXME: needs to be populated from Evidence
    evidence_direction = models.TextField(null=True)
    clinical_significance = models.TextField(null=True) # -> clinical_significance
    evidence_level = models.TextField(null=True)  # -> evidence_level (used by clinvar, oncokb)

    # evidence_type (ex: Predictive) (currently in Evidence)
    # evidence_direction (ex: Supports)
    # clinical_significance (ex: Resistance, Sensitivity/Response for 'Predictive'; Pathogenic for 'Predisposing')
    #  (currently response_type)
    # evidence_level (ex: D, C -- used by civic, oncokb) (currently evidence_label)


# all of the following are optional children of Association

class Phenotype(models.Model):
    association = models.ForeignKey(to=Association, on_delete=models.CASCADE)

    source = models.TextField(null=True)
    term = models.TextField(null=True)
    pheno_id = models.TextField(null=True)  # just called 'id' in the original object
    family = models.TextField(null=True)
    description = models.TextField(null=True)


class Evidence(models.Model):
    association = models.ForeignKey(to=Association, on_delete=models.CASCADE)

    # originally under association.evidence[].info.publications[]
    publications = ArrayField(base_field=models.TextField(), null=True, verbose_name="Publication URLs")

    # originally under association.evidence[].evidenceType.sourceName
    evidenceType_sourceName = models.TextField(null=True)
    # originally under association.evidence[].evidenceType.id
    evidenceType_id = models.TextField(null=True)


class EnvironmentalContext(models.Model):
    association = models.ForeignKey(to=Association, on_delete=models.CASCADE)

    source = models.TextField(null=True)
    term = models.TextField(null=True)
    envcontext_id = models.TextField(null=True)  # just called 'id' in the original object
    usan_stem = models.TextField(null=True)
    description = models.TextField()
