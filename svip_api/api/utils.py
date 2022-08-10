from collections import OrderedDict
from itertools import chain

from django.contrib.postgres.fields import JSONField
from django.db.models import Func, Value, F


from io import BytesIO
from django.http import HttpResponse
from django.template.loader import get_template

from xhtml2pdf import pisa


def render_to_pdf(template_src, context_dict={}):
    template = get_template(template_src)
    html = template.render(context_dict)
    result = BytesIO()
    pdf = pisa.pisaDocument(BytesIO(html.encode("UTF-8")), result)
    if not pdf.err:
        return HttpResponse(result.getvalue(), content_type='application/pdf')
    return None


def dictfetchall(cursor):
    """"Return all rows from a cursor as a dict"""
    columns = [col[0] for col in cursor.description]
    return [
        dict(zip(columns, row))
        for row in cursor.fetchall()
    ]


def field_is_empty(data, field, is_array=False):
    """
    Determines whether the field 'field' within the dict-like 'data' is empty-esque (i.e., None, '', or when stripped is '').
    If is_array is specified, the field is considered empty if it has zero elements, but is not stripped.
    :param data: the dict-like object which may contain 'field'
    :param field: the field to check
    :param is_array: whether the field's value should be examined as if it's an array
    :return: True if the field is empty, False otherwise.
    """
    if is_array:
        return field not in data or data[field] is None or len(data[field]) == 0
    return field not in data or data[field] in (None, '') or data[field].strip() == ''


def model_field_null(obj, field_name):
    """
    If relation 'field_name' doesn't exist in obj, returns True, else returns False if obj.field_name is truthy.
    """
    return not hasattr(obj, field_name) or not getattr(obj, field_name)


def format_variant(x, search_term=None, isnt_dict=False):
    """
    Produces a terse version of the variant for returning from the autocomplete endpoint; suitable for binding to the
    UI's SearchBar component.
    :param x: the variant to format
    :param search_term: the original search term, so we can figure out which field of the variant matched to display it
    :param isnt_dict: if true, extracts the contents of x as attributes into a dict
    :return: a terse representation of said variant
    """

    if isnt_dict:
        x = {
            'hgvs_c': x.hgvs_c,
            'hgvs_p': x.hgvs_p,
            'hgvs_g': x.hgvs_g,
            'id': x.id,
            'gene': x.gene.id,
            'description': x.description,
            'sources': x.sources,
        }

    target_hgvs = x['hgvs_c']

    if search_term:
        if x['hgvs_p'] and search_term in x['hgvs_p'].lower():
            target_hgvs = x['hgvs_p']
        elif x['hgvs_g'] and search_term in x['hgvs_g'].lower():
            target_hgvs = x['hgvs_g']

    return {
        'id': x['id'],
        'g_id': x['gene'],
        'type': 'v',
        'label': "%s (%s)" % (x['description'], target_hgvs.split(':')[1]) if target_hgvs else x['description'],
        'sources': sorted(x['sources']) if x['sources'] else None
    }


def to_dict(instance):
    opts = instance._meta
    data = {}
    for f in chain(opts.concrete_fields, opts.private_fields):
        data[f.name] = f.value_from_object(instance)
    for f in opts.many_to_many:
        data[f.name] = [i.id for i in f.value_from_object(instance)]
    return data


class JsonBuildObject(Func):
    function = 'jsonb_build_object'
    output_field = JSONField()


def json_build_fields(**args):
    pairs = [(Value(k), F(v)) for k, v in args.items()]
    return JsonBuildObject(
        *[item for sublist in pairs for item in sublist]
    )


class ModelChoice():
    @classmethod
    def get_choices(cls):
        return tuple(cls.__dict__.items())
