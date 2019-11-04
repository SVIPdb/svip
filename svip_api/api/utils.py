
def dictfetchall(cursor):
    """"Return all rows from a cursor as a dict"""
    columns = [col[0] for col in cursor.description]
    return [
        dict(zip(columns, row))
        for row in cursor.fetchall()
    ]


def format_variant(x):
    """
    Produces a terse version of the variant for returning from the autocomplete endpoint; suitable for binding to the
    UI's SearchBar component.
    :param x: the variant to format
    :return: a terse representation of said variant
    """
    return {
        'id': x.id,
        'g_id': x.gene.id,
        'type': 'v',
        'label': "%s (%s)" % (x.description, x.hgvs_c.split(':')[1]) if x.hgvs_c else x.description,
        'sources': sorted(x.sources)
    }
