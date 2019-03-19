import {HTTP} from "@/router/http";
import {titleCase} from "@/utils";
import {normalizeItemList} from "@/utils";
import store from "@/store";

import * as _ from 'lodash';

function parsePublicationURL(p) {
	if (!p.includes('pubmed')) {
		// parse out hostname and return that as the tooltip thingy
		const parsed = new URL(p);
		return {url: p, title: `[${parsed.hostname}]`}
	}

	const pmid = _.last(p.split("/"));
	const isPMID = /^[0-9]+$/.test(pmid);
	return {url: p, title: isPMID ? pmid : "(external)", pmid: isPMID && pmid };
}

export function makeAssociationProvider(metaUpdate=null) {
	// produces an item provider function for bootstrap-vue tables.

	// includes an optional callback when a response is received that sets metadata about the item provider update,
	// which is currently just the number of rows returned so we can set the paginator.

	return function(ctx) {
		/*
		This function is an instance of boostrap-vue's item provider interface; specifically, it produces a promise that
		eventually resolves to a list of associations. it's parameterized by a context, produced by the table, that
		specifies the sorting, paging, and filtering options to be sent to the database to produce the list of items.
		 */
		const filter_params = JSON.parse(ctx.filter);

		const params = {
			page_size: ctx.perPage,
			page: ctx.currentPage,
			ordering: (ctx.sortDesc ? '-' : '') + ctx.sortBy,
			...(filter_params && filter_params)
		}

		return HTTP.get(ctx.apiUrl, {params}).then(res => {
			// invoke the metadata updated callback, if available
			if (metaUpdate) {
				metaUpdate({
					count: res.data.count
				})
			}

			const pmid_set = _.flatten(res.data.results.map(a => {
				return _.flatten(a.evidence_set.map((ev_set) =>
					ev_set.publications.map(parsePublicationURL)
				));
			})).filter(x => x.pmid).map(x => x.pmid);

			// rewrite associations into the structure that GenericRowDetails expects
			return res.data.results.map(a => ({
				disease: a.phenotype_set.map(x => titleCase(x.term)).join("; "),
				contexts: a.environmentalcontext_set.map(x => x.description).join("; "),
				drug_labels: normalizeItemList(a.drug_labels),
				clinical_significance: a.clinical_significance,
				evidence_type: a.evidence_type,
				evidence_direction: a.evidence_direction,
				evidence_level: a.evidence_level,
				evidence_url: a.source_link,
				publications: _.flatten(a.evidence_set.map((ev_set) =>
					ev_set.publications.map(parsePublicationURL)
				))
			}));
		});
	}
}
