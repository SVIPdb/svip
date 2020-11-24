<template>
    <NotificationCard
        :items="items" :fields="fields" :loading="loading" :error="error"
        :title="$attrs.title"
        v-bind="$attrs"
    />
</template>

<script>
import NotificationCard from "@/components/widgets/curation/NotificationCard";
import { HTTP } from "@/router/http";
import uniqBy from "lodash/uniqBy";

import { abbreviatedName } from "@/utils";

const fields_on_request = [
    {
        "key": "gene_name",
        "label": "Gene",
        "sortable": true
    },
    {
        "key": "variant",
        "label": "Variant",
        "sortable": true
    },
    {
        "key": "hgvs",
        "label": "HGVS.c",
        "sortable": false
    },
    {
        "key": "disease",
        "label": "Disease(s)",
        "sortable": true
    },
    {
        "key": "status",
        "label": "Status",
        "sortable": true
    },
    {
        "key": "deadline",
        "label": "Deadline (days left)",
        "sortable": true
    },
    {
        "key": "requester",
        "label": "Requester",
        "sortable": true
    },
    {
        "key": "curator",
        "label": "Curator(s)",
        "sortable": true,
        "filterByFormatted": (x) => x.map(z => abbreviatedName(z.name).abbrev).join(", ")
    },
    {
        "key": "action",
        "label": "Action",
        "sortable": false
    }
];

export default {
    name: "OnRequestEntries",
    components: { NotificationCard },
    data() {
        return {
            loading: false,
            fields: fields_on_request,
            items: [],
            error: null
        }
    },
    created() {
        this.fetchRequestedVariants()
    },
    methods: {
        fetchRequestedVariants() {
            this.loading = true;
            this.error = null;

            HTTP.get(`/curation_entries?page_size=10000`)
                .then((response) => {
                    // reduce them to be grouped by variant
                    const entries_by_var = response.data.results.reduce((acc, x) => {
                        const key = x.variant.id;

                        if (!acc[key]) {
                            acc[key] = {
                                variant: x.variant,
                                diseases: new Set(),
                                all_curations: []
                            };
                        }

                        acc[key].all_curations.push(x);
                        acc[key].diseases.add(x.disease ? x.disease.name : 'Unspecified');

                        return acc;
                    }, {});

                    this.loading = false;

                    this.items = Object.values(entries_by_var).map(({ variant, diseases, all_curations }) => {
                        return {
                            gene_id: variant.gene.id,
                            variant_id: variant.id,
                            'gene_name': variant.gene.symbol,
                            'variant': variant.name,
                            'hgvs': variant.hgvs_c,
                            'disease': Array.from(diseases).join(", "),
                            'status': all_curations.length > 0 ? 'Ongoing' : 'Not assigned',
                            'deadline': 'n/a',
                            'requester': 'System',
                            'curator': uniqBy(all_curations.map(x => ({
                                id: x.owner,
                                name: x.owner_name
                            })), (x) => x.id)
                        };
                    });

                    this.$emit('itemsloaded', this.items);
                })
                .catch((err) => {
                    this.loading = false;
                    this.error = err.message ? err.message : true;
                })
        }
    }
}
</script>

<style scoped>

</style>
