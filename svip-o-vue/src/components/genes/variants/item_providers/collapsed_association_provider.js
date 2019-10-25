import {HTTP} from "@/router/http";
import {normalizeItemList, parsePublicationURL, titleCase} from "@/utils";
import * as _ from "lodash";

export function makeCollapsedAssociationProvider(metaUpdate = null) {
    // produces an item provider function for bootstrap-vue tables.

    // includes an optional callback when a response is received that sets metadata about the item provider update,
    // which is currently just the number of rows returned so we can set the paginator.

    return function (ctx) {
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
        };

        return HTTP.get(ctx.apiUrl, {params}).then(res => {
            // invoke the metadata updated callback, if available
            if (metaUpdate) {
                metaUpdate({
                    count: res.data.count
                })
            }

            // rewrite some fields into what the front-end's expecting
            // fixme: should these be migrated to the tables themselves?
            return res.data.results.map(a => ({
                    ...a,
                    disease: titleCase(a.disease),
                    drug_labels: normalizeItemList(a.drug_labels),
                    publications: a.publications.map(parsePublicationURL),
                    /* silly hack: we make all the details panels expanded, and just expand/collapse their contents so we can animate them */
                    _showDetails: true,
                    _animatedDetails: false
                })
            )
        });
    }
}
