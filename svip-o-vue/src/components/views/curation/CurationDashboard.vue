<template>
    <div class="container-fluid">
        <div v-if="checkInRole('reviewers')">
            <!-- ON REQUEST - CARD -->
            <NotificationCard v-if="REVIEW_ENABLED"
                :items="on_request.items"
                :fields="on_request.fields"
                defaultSortBy="days_left"
                title="ON REQUEST"
                cardHeaderBg="secondary"
                cardTitleVariant="white"
                cardCustomClass
                cardFilterOption
            />
            <!-- TO BE CURATED - CARD -->
            <NotificationCard v-if="REVIEW_ENABLED"
                :items="to_be_curated"
                :fields="fields_to_be_curated"
                defaultSortBy="days_left"
                title="TO BE CURATED"
                cardFilterOption
            />
            <!-- UNDER REVISION - CARD -->
            <NotificationCard v-if="REVIEW_ENABLED"
                :items="to_be_discussed"
                :fields="fields_to_be_discussed"
                defaultSortBy="days_left"
                title="TO BE DISCUSSED"
            />
            <!-- NON SVIP VARIANTS - CARD -->
            <!--
            <NotificationCard
                :items="nonsvip_variants"
                :fields="fields_nonsvip_variants"
                title="NON SVIP VARIANTS"
            />
            -->
        </div>

        <div v-else-if="checkInRole('curators')">
            <!-- TBC: request queue -->
            <NotificationCard
                :items="on_request.items" :fields="on_request.fields" :loading="on_request.loading"
                defaultSortBy="days_left"
                title="ON REQUEST"
                cardHeaderBg="secondary"
                cardTitleVariant="white"
                cardCustomClass
                cardFilterOption
            />

            <EvidenceCard has-header is-dashboard
                header-title="CURATION ENTRIES"
                cardHeaderBg="secondary"
                cardTitleVariant="white"
                small
            />
        </div>

        <div v-else style="text-align: center; margin-top: 3em;">
            <h1>Not Authorized</h1>
            <p>You may only access this page if you're a curator or reviewer.</p>
            <router-link to="/">return to homepage</router-link>
        </div>
    </div>
</template>

<script>
import { HTTP } from "@/router/http";
import flatMap from 'lodash/flatMap';
import uniqBy from 'lodash/uniqBy';
import NotificationCard from "@/components/curation/widgets/NotificationCard";
import EvidenceCard from "@/components/curation/widgets/EvidenceCard";
import {checkInRole} from "@/directives/access";

// Manual import of fake data (FIXME: API)
import on_request from "@/data/curation/on_request/items.json";
import fields_on_request from "@/data/curation/on_request/fields.js";

import to_be_curated from "@/data/curation/to_be_curated/items.json";
import fields_to_be_curated from "@/data/curation/to_be_curated/fields.json";

import to_be_discussed from "@/data/curation/to_be_discussed/items.json";
import fields_to_be_discussed from "@/data/curation/to_be_discussed/fields.json";

import nonsvip_variants from "@/data/curation/nonsvip_variants/items.json";
import fields_nonsvip_variants from "@/data/curation/nonsvip_variants/fields.json";
import {abbreviatedName} from "@/utils";

export default {
    name: "CurationDashboard",
    components: {
        EvidenceCard,
        NotificationCard
    },
    data() {
        return {
            REVIEW_ENABLED: false, // temporary flag to hide review-related bits of the UI until they're ready

            // ON REQUEST FAKE DATA
            on_request: {
                loading: false,
                fields: fields_on_request,
                items: []
            },

            // TO BE CURATED FAKE DATA
            to_be_curated, // data
            fields_to_be_curated, // columns

            // TO BE DISCUSSED FAKE DATA
            to_be_discussed, // data
            fields_to_be_discussed, // columns

            // NON SVIP VARIANTS FAKE DATA
            nonsvip_variants, // data
            fields_nonsvip_variants // columns
        };
    },
    created() {
        this.fetchRequestedVariants();
    },
    methods: {
        checkInRole,
        fetchRequestedVariants() {
            this.on_request.loading = true;
            HTTP.get(`/variants?in_svip=true&inline_svip_data=true&page_size=10000`).then((response) => {
                this.on_request.loading = false;

                this.on_request.items = response.data.results.map((entry) => {
                    const all_curations = flatMap(entry.svip_data.diseases, x => x.curation_entries);

                    return {
                        gene_id: entry.gene.id,
                        variant_id: entry.id,
                        'gene_name': entry.gene.symbol,
                        'variant': entry.name,
                        'hgvs': entry.hgvs_c,
                        'disease': entry.svip_data.diseases.map(x => x.name).join(", "),
                        'status': all_curations.length > 0 ? 'Ongoing' : 'Not assigned',
                        'deadline': 'n/a',
                        'requester': 'System',
                        'curator': uniqBy(all_curations.map(x => ({ id: x.owner, name: x.owner_name })), (x) => x.id)
                    };
                });
            })
        }
    }
};
</script>

<style scoped>
.variant-card .card-body {
    padding: 0;
}

.variant-header {
    margin-bottom: 0;
}

.variant-header td,
.variant-header th {
    vertical-align: text-bottom;
    padding: 1rem;
}

.aliases-list {
    font-style: italic;
}

.details-row {
    background: #eee;
    box-shadow: inset;
}

/* Enter and leave animations can use different */
/* durations and timing functions.              */
.slide-fade-enter-active {
    transition: all 0.5s ease;
}

.slide-fade-leave-active {
    transition: all 0.3s ease;
}

.slide-fade-enter-to,
.slide-fade-leave {
    max-height: 120px;
}

.slide-fade-enter, .slide-fade-leave-to
    /* .slide-fade-leave-active below version 2.1.8 */ {
    opacity: 0;
    max-height: 0;
}
</style>
