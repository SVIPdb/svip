export function change_from_hgvs(x) {
    if (!x || !x.includes(':'))
        return x;

    return x.split(':')[1];
}

export function var_to_position(variant, with_change = false) {
    const r = /.*:g\.([0-9]+)(.*)$/;

    if (!variant.hgvs_g || !variant.chromosome || !variant.hgvs_g.match(r))
        return null;

    if (with_change) {
        return `chr${variant.chromosome}:${variant.hgvs_g.replace(r, '$1$2')}`;
    }

    return `chr${variant.chromosome}:${variant.hgvs_g.replace(r, '$1')}`;
}

export function titleCase(str, glue = ['of', 'for', 'and']) {
    return str.replace(/(\w)(\w*)/g, function(_, i, r) {
        const j = i.toUpperCase() + (r != null ? r : "");
        return (glue.indexOf(j.toLowerCase()) < 0) ? j : j.toLowerCase();
    });
}
