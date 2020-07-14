from django.http import JsonResponse

def _nice_username(obj):
    fullname = ("%s %s" % (obj.first_name, obj.last_name)).strip()
    return fullname if fullname else obj.username

def identity_mapper(f, v):
    return v

def make_history_response(entry, remapper=identity_mapper, add_created_by=True):
    entry_history = list(entry.history.all())
    deltas = (
        {
            'time': a.history_date,
            'diff': a.diff_against(b),
            'history_user': _nice_username(a.history_user)
        }
        for a, b in zip(entry_history[:-1], entry_history[1:])
    )

    resp = {
        'created_on': entry_history[-1].history_date if len(entry_history) > 0 else None,
        'deltas': [
            {
                'time': str(delta['time']),
                'changed_by': delta['history_user'],
                'changes': [
                    {
                        'field': change.field,
                        'old': remapper(change.field, change.old),
                        'new': remapper(change.field, change.new)
                    }
                    for change in delta['diff'].changes
                ]
            }
            for delta in deltas
        ]
    }

    if add_created_by:
        resp['created_by'] = _nice_username(entry.owner)

    return JsonResponse(resp)
