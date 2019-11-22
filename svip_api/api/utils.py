from itertools import chain

def dictfetchall(cursor):
    """"Return all rows from a cursor as a dict"""
    columns = [col[0] for col in cursor.description]
    return [
        dict(zip(columns, row))
        for row in cursor.fetchall()
    ]


def format_variant(x, search_term=None):
    """
    Produces a terse version of the variant for returning from the autocomplete endpoint; suitable for binding to the
    UI's SearchBar component.
    :param x: the variant to format
    :param search_term: the original search term, so we can figure out which field of the variant matched to display it
    :return: a terse representation of said variant
    """

    target_hgvs = x.hgvs_c

    if search_term:
        if x.hgvs_p and search_term in x.hgvs_p.lower():
            target_hgvs = x.hgvs_p
        elif x.hgvs_g and search_term in x.hgvs_g.lower():
            target_hgvs = x.hgvs_g

    return {
        'id': x.id,
        'g_id': x.gene.id,
        'type': 'v',
        'label': "%s (%s)" % (x.description, target_hgvs.split(':')[1]) if target_hgvs else x.description,
        'sources': sorted(x.sources)
    }


def to_dict(instance):
    opts = instance._meta
    data = {}
    for f in chain(opts.concrete_fields, opts.private_fields):
        data[f.name] = f.value_from_object(instance)
    for f in opts.many_to_many:
        data[f.name] = [i.id for i in f.value_from_object(instance)]
    return data
