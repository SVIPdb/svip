from random import randint

from django.contrib.auth import get_user_model

from api.models import CurationEntry, Disease, Variant, Gene
from api.models.svip import SubmissionEntry, CurationReview


def create_user(user_data={}):
    """Create and return a new user."""
    if user_data:
        payload = user_data
    else:
        payload = {
            "username": f"test_user{str(randint(1, 10000))}",
            "password": "testpass123"
        }
    return get_user_model().objects.create(**payload)


def create_gene(**params):
    defaults = {"entrez_id": randint(1000, 10000),
                "ensembl_gene_id": "ENSG00000103197",
                "symbol": f"TSC{str(randint(1, 10000))}",
                "uniprot_ids": [
                    "P49815"
                ],
                "location": "16p13.3",
                "summary": "",
                "summary_date": "2020-07-14T22:07:45.959574Z",
                "sources": [
                    "civic",
                    "clinvar",
                    "cosmic",
                    "oncokb",
                    "svip_queue"
                ],
                "aliases": [
                    "LAM",
                    "PPP1R160",
                    "tuberin"
                ],
                "prev_symbols": [
                    "TSC4"
                ]}
    defaults.update(params)
    return Gene.objects.create(**defaults)


def create_variant(**params):
    defaults = {
        "gene": create_gene(),
        "name": "?",
        "description": "TSC2 ?",
        "biomarker_type": "Deletion",
        "so_hierarchy": None,
        "soid": "required",
        "so_name": None,
        "reference_name": "GRCh37",
        "refseq": None,
        "isoform": None,
        "chromosome": "16",
        "start_pos": -1,
        "end_pos": -1,
        "ref": None,
        "alt": None,
        "hgvs_g": "NC_000016.9:g.(?_2112498)_(2114428_?)del",
        "hgvs_c": None,
        "hgvs_p": "LRG_487p1:p.?",
        "somatic_status": None,
        "dbsnp_ids": [],
        "myvariant_hg19": None,
        "sources": [
            "clinvar"
        ],
        "crawl_status": None,

    }

    defaults.update(params)
    return Variant.objects.create(**defaults)


def create_disease(**params):
    defaults = {
        "created_on": "2020-07-14T22:07:45.959574Z"
    }

    defaults.update(params)
    return Disease.objects.create(**defaults)


def create_curation_entry(**params):
    """Create and return a sample curation entry."""
    defaults = {
        "disease": create_disease(),
        "variant": create_variant(),
        "type_of_evidence": "In vivo assay",
        "interactions": None,
        "effect": "Pathogenic",
        "tier_level_criteria": "Well-established in vivo functional study showing a deleterious effect",
        "tier_level": None,
        "escat_score": None,
        "mutation_origin": "Unknown",
        "associated_mendelian_diseases": None,
        "summary": "The article shows that NPM1 mutations type A,  B, C, D, E, F (exon 12 mutations) cause protein dislocation to cytoplasm:  NIH-3T3 cells were transiently transfected with expression vectors encoding wild-type and mutant alleles fused with EGFP. Confocal microscopy showed nucleolar localization of the EGFP–NPM wild-type protein. The mutant form of NPM was dislocated into the cytoplasm.\nAdditional information: This variant is not found in gnomAD (http://gnomad.broadinstitute.org/transcript/ENST00000296930?dataset=gnomad_r2_1). It is called NPM1 type A mutation and has a TCTG tetranucleotide repeat. In AML, it represents 75% to 80% of all NPM1 mutations (from review article PMID: 29157973) and it is a clinically relevant variant. It is accepted that NPM1 dislocation from nucleolus to cytoplasm is a critical event in leukemogenesis (review PMID:19516275). Beside mutation type A, other genetic NPM1 alterations frequently found in lymphomas and leukemias perturb the cellular traffic of nucleophosmin.  For example: Anaplastic large cell lymphoma (ALCL). ALCL cells harbouring the t(2;5) translocation (about 85% of cases) express both NPM1–ALK fusion protein and NPM1wt (encoded by the residual NPM1 allele). Because of its ALK moiety, at least a proportion of the NPM1–ALK protein anchors to ALCL cell cytoplasm. This accounts for the aberrant cytoplasmic expression of nucleophosmin that is revealed with antibodies against the NPM1 N-terminus (which is retained in the fusion protein).  In contrast, NPM1wt that can be detected with an antibody against NPM1 C-terminus (that is not retained in NPM1–ALK), maintains its expected nucleolar expression in ALCL with t(2;5).",
        "support": "Strong",
        "comment": "We need to agree on what is in vitro and in vivo assay.",
        "references": "PMID: 15659725",
        "annotations": [],
        "created_on": "2019-11-22T13:02:41.784424Z",
        "last_modified": "2021-10-20T13:18:57.573065Z",
        "owner": create_user(),
        "status": "draft",

    }
    defaults.update(params)

    return CurationEntry.objects.create(**defaults)


def create_submission_entry(**params):
    """Create and return a sample submission entry."""
    defaults = {"owner_id": create_user().id,
                "variant_id": create_variant().id,
                "disease_id": create_disease().id,
                "effect": "Associated with diagnosis",
                "drug": "Fuflomicin",
                "type_of_evidence": "Predictive / Therapeutic - Fuflomicin",
                "tier": "Reported evidence supportive of benign/likely benign effect"
                }

    defaults.update(params)
    return SubmissionEntry.objects.create(**defaults)


def create_review(**params):
    defaults = {'submission_entry': create_submission_entry(),
                'annotated_effect': 'Poor outcome',
                'annotated_tier': 'IID Tier',
                'comment': 'Some comment',
                'draft': True,
                'reviewer': create_user(),
                'acceptance': True}
    defaults.update(params)
    return CurationReview.objects.create(**defaults)
