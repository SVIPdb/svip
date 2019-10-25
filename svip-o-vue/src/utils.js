import * as _ from "lodash";
import slugify from "slugify";

export function change_from_hgvs(x, include_transcript = false) {
    if (!x || !x.includes(":")) return x;

    if (include_transcript) {
        const parts = x.split(":");
        return {transcript: parts[0], change: parts[1]};
    }

    return x.split(":")[1];
}

export function var_to_position(variant, with_change = false) {
    const r = /.*:g\.([0-9]+)(.*)$/;

    if (!variant.hgvs_g || !variant.chromosome || !variant.hgvs_g.match(r))
        return null;

    if (with_change) {
        return `chr${variant.chromosome}:${variant.hgvs_g.replace(r, "$1$2")}`;
    }

    return `chr${variant.chromosome}:${variant.hgvs_g.replace(r, "$1")}`;
}

export function normalizeItemList(items) {
    if (!items) return items;

    return items
        .split(",")
        .map(x => x.trim())
        .join(", ");
}

export function titleCase(str, lowerCaseAll = false, glue = ["of", "for", "and"]) {
    if (!str) {
        return str;
    }
    return str.replace(/(\w)(\w*)/g, function (_, i, r) {
        const frag = (r != null ? r : "");
        const j = i.toUpperCase() + (lowerCaseAll ? frag.toLocaleLowerCase() : frag);
        return glue.indexOf(j.toLowerCase()) < 0 ? j : j.toLowerCase();
    });
}

export function desnakify(x, lowerCaseAll = false) {
    if (!x) {
        return x;
    }
    return titleCase(x.split("_").join(" "), lowerCaseAll);
}

export function millisecondsToStr(milliseconds) {
    /***
     * Prints 'milliseconds' as a human-readable duration, e.g. 11y 51d 10h 2m 16.00s
     * @type {number}
     */
    let temp = milliseconds / 1000;
    const years = Math.floor(temp / 31536000),
        days = Math.floor((temp %= 31536000) / 86400),
        hours = Math.floor((temp %= 86400) / 3600),
        minutes = Math.floor((temp %= 3600) / 60),
        seconds = temp % 60;

    if (days || hours || seconds || minutes) {
        return (years ? years + "y " : "") +
            (days ? days + "d " : "") +
            (hours ? hours + "h " : "") +
            (minutes ? minutes + "m " : "") +
            Number.parseFloat(seconds).toFixed(0) + "s";
    }

    return "< 1s";
}

export function trimPrefix(str, prefix) {
    return (str.startsWith(prefix)) ? str.slice(prefix.length) : str;
}

export function slugifySans(x) {
    return slugify(x.replace(":", "_"));
}

// used by some item providers to parse PMIDs out of publication URLs
export function parsePublicationURL(p) {
    if (!p.includes('pubmed')) {
        // parse out hostname and return that as the tooltip thingy
        const parsed = new URL(p);
        return {url: p, title: `[${parsed.hostname}]`}
    }

    const pmid = _.last(p.split("/"));
    const isPMID = /^[0-9]+$/.test(pmid);
    return {url: p, title: isPMID ? pmid : "(external)", pmid: isPMID && pmid};
}
