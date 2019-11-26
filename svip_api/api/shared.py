"""
Methods that cut across different levels of the model/serializer/view hierarchy or across different data domains.
"""
from django.db.models import Value
from django.db.models.functions import Concat


def pathogenic(ce_entries):
    """
    Converts a series of curation entries (ideally pre-filtered by user permissions) into a single value
    that summarizes the set's pathogenicity.

    :param ce_entries: a QuerySet of CurationEntry elements
    :return: either "Pathogenic", "Pathogenic (unreviewed)", or None (subject to change in the future)
    """
    # first off, the easy case: there's one reviewed entry that lists the effect as pathogenic
    if ce_entries.filter(status='reviewed', effect='Pathogenic').exists():
        return 'Pathogenic'

    # otherwise, report that it's pending if we do find a pathogenic entry, but it's not reviewed
    return 'Pathogenic (unreviewed)' if ce_entries.filter(effect='Pathogenic').exists() else None


def clinical_significance(ce_entries):
    """
    Converts a series of curation entries (ideally pre-filtered by user permissions) into a delimited
    string summarizing the clinical significances of the entries.

    :param ce_entries: a QuerySet of CurationEntry elements
    :return: a concatenation of type_of_evidence (tier_level) for all relevant elements (e.g., Predictive/Prognostic)
    """
    return ', '.join(
        x['combined'] for x in ce_entries
            .filter(type_of_evidence__in=('Predictive / Therapeutic', 'Prognostic'))
            .annotate(combined=Concat('type_of_evidence', Value(' ('), 'tier_level', Value(')')))
            .values('combined').distinct()
    )
