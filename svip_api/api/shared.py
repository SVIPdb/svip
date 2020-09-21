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

    patho_exists = False

    for entry in ce_entries:
        if entry.effect == 'Pathogenic':
            patho_exists = True

            # first off, the easy case: there's one reviewed entry that lists the effect as pathogenic
            if entry.status == 'reviewed':
                return 'Pathogenic'

    # otherwise, report that it's pending if we do find a pathogenic entry, but it's not reviewed
    return 'Pathogenic (unreviewed)' if patho_exists else None


def clinical_significance(ce_entries):
    """
    Converts a series of curation entries (ideally pre-filtered by user permissions) into a delimited
    string summarizing the clinical significances of the entries.

    :param ce_entries: a QuerySet of CurationEntry elements
    :return: a concatenation of type_of_evidence (tier_level) for all relevant elements (e.g., Predictive/Prognostic)
    """

    return ', '.join(set(
        '%s (%s)' % (x.type_of_evidence, x.tier_level)
        for x in ce_entries
        if x.type_of_evidence in ('Predictive / Therapeutic', 'Prognostic')
    ))
