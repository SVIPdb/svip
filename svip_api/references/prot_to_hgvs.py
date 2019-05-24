import re

# added to map strings like 'V600E' to the hgvs-esque 'p.Val600Glu'
one_to_three = {
    'A': 'Ala',
    'B': 'Asx',
    'C': 'Cys',
    'D': 'Asp',
    'E': 'Glu',
    'F': 'Phe',
    'G': 'Gly',
    'H': 'His',
    'I': 'Ile',
    'K': 'Lys',
    'L': 'Leu',
    'M': 'Met',
    'N': 'Asn',
    'P': 'Pro',
    'Q': 'Gln',
    'R': 'Arg',
    'S': 'Ser',
    'T': 'Thr',
    'U': 'Sec',
    'V': 'Val',
    'W': 'Trp',
    'Xa': 'Xaa',
    'Y': 'Tyr',
    'Z': 'Glx',
    '*': '*',
    'X': '*'  # based on an observation in lou's code that civic uses 'X' as a stop codon, too
}

three_to_one = dict((v, k) for k, v in one_to_three.items())

# maps internal single-character references to proteins with their HGVS-compliant three-letter abbreviation
# also normalizes some alteration keywords, e.g. "DELins" should be "delins"
protein_ops = {
    'missense': {
        # a single codon change, e.g. V600E
        'rx': re.compile('^(?P<ref>[A-Z])(?P<pos>[0-9]+)(?P<alt>[A-Z])$'),
        'mapped': lambda d: '%s%d%s' % (one_to_three[d['ref']], int(d['pos']), one_to_three[d['alt']])
    },
    'insertion': {
        # an insertion, e.g. V444_G446insHH
        'rx': re.compile('^(?P<ref_a>[a-zA-Z])(?P<pos_a>[0-9]+)_(?P<ref_b>[a-zA-Z])(?P<pos_b>[0-9]+)(ins|INS)(?P<alts>[A-Z]+)$'),
        'mapped': lambda d: '%s%d_%s%dins%s' % (
            one_to_three[d['ref_a']], int(d['pos_a']),
            one_to_three[d['ref_b']], int(d['pos_b']),
            ''.join(one_to_three[x] for x in d['alts'])
        )
    },
    'deldup_single': {
        # either a deletion or a duplication, merged here since they follow the same syntax
        # e.g., V455del
        # to explain the 'extra' stuff, sometimes we encounter deletions where the deletion itself is specified, e.g.
        # 'K745_E749delKELRE' (a deletion of 15 bases) or 'S752_I759delSPKANKEI' (a deletion of 24 bases)
        # we just strip out the extra parts, since it's implied in the range
        'rx': re.compile(
            '^(?P<ref>[a-zA-Z])(?P<pos>[0-9]+)(?P<type>(del|dup))(?P<extra>[A-Z]+)?$'),
        'mapped': lambda d: '%s%d%s' % (one_to_three[d['ref']], int(d['pos']), d['type'])
    },
    'deldup_many': {
        # a range of deletions/duplications, e.g. V455_G499dup
        # (see deldup_single for an explanation of the 'extra' bit)
        'rx': re.compile(
            '^(?P<ref_a>[a-zA-Z])(?P<pos_a>[0-9]+)_(?P<ref_b>[a-zA-Z])(?P<pos_b>[0-9]+)(?P<type>(del|dup))(?P<extra>[A-Z]+)?$'),
        'mapped': lambda d: '%s%d_%s%d%s' % (
            one_to_three[d['ref_a']], int(d['pos_a']),
            one_to_three[d['ref_b']], int(d['pos_b']),
            d['type']
        )
    },
    # FIXME: civic unfortunately uses "V600", say, as a catch-all for V600-affecting variants, e.g. V600E, V600L
    # that's terrible for a number of reasons, but it also means we can't treat V600 as shorthand for a deletion
    # 'deletion_single_abbrev': {
    #     'rx': re.compile(
    #         '^(?P<ref>[a-zA-Z])(?P<pos>[0-9]+)$'),
    #     'mapped': lambda d: '%s%ddel' % (one_to_three[d['ref']], int(d['pos']))
    # },
    # 'deletion_multiple_abbrev': {
    #     'rx': re.compile(
    #         '^(del)?(?P<ref_a>[a-zA-Z])(?P<pos_a>[0-9]+)_(?P<ref_b>[a-zA-Z])(?P<pos_b>[0-9]+)$'),
    #     'mapped': lambda d: '%s%d_%s%ddel' % (
    #         one_to_three[d['ref_a']], int(d['pos_a']),
    #         one_to_three[d['ref_b']], int(d['pos_b'])
    #     )
    # },
    'delins_single': {
        # a single delins, e.g. G466delinsHH
        'rx': re.compile(
            '^(?P<ref>[a-zA-Z])(?P<pos>[0-9]+)(delins|DELins|>)(?P<alts>[A-Z]+)$'),
        'mapped': lambda d: '%s%ddelins%s' % (
            one_to_three[d['ref']], int(d['pos']),
            ''.join(one_to_three[x] for x in d['alts'])
        )
    },
    'delins_single_alternate': {
        # a different format for specifying a single-protein delins, e.g. delG444insHH
        'rx': re.compile(
            '^del(?P<ref>[a-zA-Z])(?P<pos>[0-9]+)ins(?P<alts>[A-Z]+)$'),
        'mapped': lambda d: '%s%ddelins%s' % (
            one_to_three[d['ref']], int(d['pos']),
            ''.join(one_to_three[x] for x in d['alts'])
        )
    },
    'delins_many': {
        # a delins over a range, e.g. G444_G466delinsHH
        'rx': re.compile(
            '^(?P<ref_a>[a-zA-Z])(?P<pos_a>[0-9]+)_(?P<ref_b>[a-zA-Z])(?P<pos_b>[0-9]+)(delins|DELins|>)(?P<alts>[A-Z]+)$'),
        'mapped': lambda d: '%s%d_%s%ddelins%s' % (
            one_to_three[d['ref_a']], int(d['pos_a']),
            one_to_three[d['ref_b']], int(d['pos_b']),
            ''.join(one_to_three[x] for x in d['alts'])
        )
    },
    'delins_many_alternate': {
        # the ranged version of delins_single_alternate, e.g. delG444_G466insHH
        'rx': re.compile(
            '^del(?P<ref_a>[a-zA-Z])(?P<pos_a>[0-9]+)_(?P<ref_b>[a-zA-Z])(?P<pos_b>[0-9]+)ins(?P<alts>[A-Z]+)$'),
        'mapped': lambda d: '%s%d_%s%ddelins%s' % (
            one_to_three[d['ref_a']], int(d['pos_a']),
            one_to_three[d['ref_b']], int(d['pos_b']),
            ''.join(one_to_three[x] for x in d['alts'])
        )
    },
}


def to_hgvs_p(basic):
    for op, v in protein_ops.items():
        rx, mapped = v['rx'], v['mapped']
        result = rx.match(basic)
        if result:
            return "p.%s" % mapped(result.groupdict())
    return None
