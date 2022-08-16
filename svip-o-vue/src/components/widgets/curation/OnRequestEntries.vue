<template>
    <NotificationCard
        :items="items"
        :fields="fields"
        :loading="loading"
        :error="error"
        :title="$attrs.title"
        v-bind="$attrs" />
</template>

<script>
import NotificationCard from "@/components/widgets/curation/NotificationCard";
import { HTTP } from "@/router/http";
//import uniqBy from "lodash/uniqBy";

import { abbreviatedName } from "@/utils";

const fields_on_request = [
    {
        key: "gene_name",
        label: "Gene",
        sortable: true,
    },
    {
        key: "variant",
        label: "Variant",
        sortable: true,
    },
    {
        key: "hgvs",
        label: "HGVS.c",
        sortable: false,
    },
    {
        key: "disease",
        label: "Disease(s)",
        sortable: true,
    },
    {
        key: "status",
        label: "Status",
        sortable: true,
    },
    {
        key: "deadline",
        label: "Deadline (days left)",
        sortable: true,
    },
    {
        key: "requester",
        label: "Requester",
        sortable: true,
    },
    {
        key: "curator",
        label: "Curator(s)",
        sortable: true,
        filterByFormatted: x =>
            x.map(z => abbreviatedName(z.name).abbrev).join(", "),
    },
    {
        key: "action",
        label: "Action",
        sortable: false,
    },
];

export default {
    name: "OnRequestEntries",
    components: { NotificationCard },
    data() {
        return {
            loading: false,
            fields: fields_on_request,
            items: [],
            error: null,
        };
    },
    created() {
        this.fetchRequestedVariants();
    },
    methods: {
        calculateStage(stage) {
            if (stage === "loaded") {
                return "Not assigned";
            } else if (stage === "ongoing_curation") {
                return "Ongoing";
            } else if (stage === "unapproved") {
                return "To be recurated";
            } else {
                return "Completed";
            }
        },
        fetchRequestedVariants() {
            this.loading = true;
            this.error = null;

            HTTP.get(`/curation_requests?page_size=100000`)
                .then(response => {
                    this.loading = false;
                    this.items = response.data.results.map(x => ({
                        gene_id: x.variant && x.variant.gene.id,
                        variant_id: x.variant && x.variant.id,
                        gene_name: x.variant && x.variant.gene.symbol,
                        variant: x.variant && x.variant.name,
                        hgvs: x.variant && x.variant.hgvs_c,
                        disease: x.disease_name,
                        //'status': x.all_curations_count > 0 ? 'Ongoing' : 'Not assigned',
                        status: this.calculateStage(x.variant.stage),
                        deadline: "n/a",
                        requester: x.submission.requestor,
                        curator: [],
                        review_count: x.variant.review_count,
                        reviews: x.variant.reviews,
                        stage: x.variant.stage,
                    }));

                    this.$emit("itemsloaded", this.items);
                })
                .catch(err => {
                    this.loading = false;
                    this.error = err.message ? err.message : true;
                });
        },
    },
};
</script>

<style scoped></style>
