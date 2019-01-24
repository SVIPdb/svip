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
    # FIXME: this is currently unpopulated; decide if we want to replace 'sources' in Gene/Variant with a ref to this
    name = models.CharField(max_length=100, null=False, unique=True, db_index=True)


class Gene(models.Model):
    entrez_id = models.BigIntegerField(unique=True, db_index=True)
    ensembl_gene_id = models.CharField(max_length=20, db_index=True)
    symbol = models.CharField(max_length=10, unique=True, db_index=True)
    uniprot_ids = ArrayField(base_field=models.TextField(), null=True, verbose_name="UniProt IDs")
    location = models.TextField(null=True)

    # this object is used as a set; to add an entry: sources = jsonb_set(sources, '{newfield}', null, TRUE)
    sources = JSONField(default=dict)

    # sources = ArrayField(
    #     base_field=models.ForeignKey(to=Source, to_field='name', on_delete=models.CASCADE), default=list)

    def __str__(self):
        return "%s (entrez id: %d)" % (self.symbol, self.entrez_id)


class Variant(models.Model):
    gene = models.ForeignKey(to=Gene, on_delete=models.CASCADE)

    name = models.CharField(max_length=120, null=False, db_index=True, verbose_name="Variant Name")
    description = models.TextField(null=True, db_index=True)

    biomarker_type = models.CharField(max_length=30, null=True)
    so_hierarchy = ArrayField(base_field=models.CharField(max_length=15), null=True, verbose_name="Hierarchy of SO IDs")
    soid = models.CharField(max_length=15, null=True, verbose_name="Sequence Ontology ID", default="")
    so_name = models.CharField(max_length=30, null=True)

    reference_name = models.CharField(max_length=30, null=True)  # e.g., GRCh37
    refseq = models.CharField(max_length=60, null=True)
    isoform = models.CharField(max_length=120, null=True)

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

    sources = JSONField(default=dict)

    def __str__(self):
        return "%s %s" % (self.gene.symbol, self.name)

    class Meta:
        indexes = [
            models.Index(fields=['gene', 'name'])
        ]


# ***WIP***
# class ImpactPrediction(models.Model):
#     variant = models.ForeignKey(to=Variant, on_delete=models.CASCADE)
#
#     source = models.CharField(max_length=30)
#     score = models.FloatField(null=True)

# represents the connection between a variant and evidence items (augmented by env. context, possibly producing
# phenotypes)

class Association(models.Model):
    """
    Represents the connection between a Variant and its Phenotypes, Evidences, and EnvironmentalContexts
    """
    gene = models.ForeignKey(to=Gene, on_delete=models.CASCADE)
    variant = models.ForeignKey(to=Variant, on_delete=models.CASCADE)

    source_url = models.TextField(null=True)
    source = models.CharField(max_length=30)

    # temporary field to log exactly what we're getting from the server
    payload = JSONField(default=dict)

    description = models.TextField(null=True)
    drug_labels = models.CharField(max_length=120, null=True)

    variant_name = models.TextField(null=True)  # here for debugging, remove if it's always the name as Variant__name
    source_link = models.TextField(null=True)

    evidence_label = models.CharField(max_length=20, null=True)
    response_type = models.CharField(max_length=20, null=True)
    evidence_level = models.CharField(max_length=20, null=True)


# all of the following are optional children of Association

class Phenotype(models.Model):
    association = models.ForeignKey(to=Association, on_delete=models.CASCADE)

    source = models.CharField(max_length=120, null=True)
    term = models.CharField(max_length=120, null=True)
    pheno_id = models.CharField(max_length=120, null=True)  # just called 'id' in the original object
    family = models.CharField(max_length=120, null=True)
    description = models.TextField(null=True)


class Evidence(models.Model):
    association = models.ForeignKey(to=Association, on_delete=models.CASCADE)

    type = models.CharField(max_length=20, choices=EVIDENCE_TYPES)
    description = models.TextField(null=True)

    # originally under association.evidence[].info.publications[]
    publications = ArrayField(base_field=models.TextField(), null=True, verbose_name="Publication URLs")

    # originally under association.evidence[].evidenceType.sourceName
    evidenceType_sourceName = models.CharField(max_length=120, null=True)
    # originally under association.evidence[].evidenceType.id
    evidenceType_id = models.CharField(max_length=120, null=True)


class EnvironmentalContext(models.Model):
    association = models.ForeignKey(to=Association, on_delete=models.CASCADE)

    source = models.CharField(max_length=120, null=True)
    term = models.CharField(max_length=120)
    envcontext_id = models.CharField(max_length=120, null=True)  # just called 'id' in the original object
    usan_stem = models.CharField(max_length=120, null=True)
    description = models.TextField()
