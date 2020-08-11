<template>
    <div class="container-fluid">
        <!-- Ivo - suggestion : replace ':reviewer="true"' by '_reviewer="checkInRole('reviewers')"' ??? -->
        <div><!-- Ivo - original : <div v-if="checkInRole('reviewers')"> -->
            <!-- Ivo : is it normal that there is no record in review? PS: change :items="review.items" -->
            <!-- ON REQUEST - CARD -->
            <NotificationCard v-if="REVIEW_ENABLED"
                :items="on_request.items" :fields="review.fields" :loading="review.loading"
                :isReviewer="true"
                title="REVIEWS"
                defaultSortBy="days_left"
                cardHeaderBg="secondary"
                cardTitleVariant="white"
                cardCustomClass
                cardFilterOption
            />
        </div>

        <!-- Ivo - original : <div v-else-if="checkInRole('curators')"> -->
        <div v-if="checkInRole('curators')">
            <!-- TBC: request queue -->
            <NotificationCard
                :items="on_request.items" :fields="on_request.fields" :loading="on_request.loading"
                :isCurator="true"
                defaultSortBy="days_left"
                title="ON REQUEST"
                cardHeaderBg="secondary"
                cardTitleVariant="white"
                cardCustomClass
                cardFilterOption
            />

            <EvidenceCard has-header include-gene-var
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
import NotificationCard from "@/components/widgets/curation/NotificationCard";
import EvidenceCard from "@/components/widgets/curation/EvidenceCard";
import { checkInRole } from "@/directives/access";
// Manual import of fake data (FIXME: API)
import fields_on_request from "@/data/curation/on_request/fields.js";
// Manual import of fake data (FIXME: API)
import fields_review from "@/data/review/fields.js";

import to_be_curated from "@/data/curation/to_be_curated/items.json";
import fields_to_be_curated from "@/data/curation/to_be_curated/fields.json";

import to_be_discussed from "@/data/curation/to_be_discussed/items.json";
import fields_to_be_discussed from "@/data/curation/to_be_discussed/fields.json";

import nonsvip_variants from "@/data/curation/nonsvip_variants/items.json";
import fields_nonsvip_variants from "@/data/curation/nonsvip_variants/fields.json";

export default {
    name: "CurationDashboard",
    components: {
        EvidenceCard,
        NotificationCard
    },
    data() {
        return {
            // Ivo - orignial : REVIEW_ENABLED: false,
            REVIEW_ENABLED: true, // temporary flag to hide review-related bits of the UI until they're ready

            // ON REQUEST FAKE DATA
            on_request: {
                loading: false,
                fields: fields_on_request,
                items: []
            },

            // REVIEW FAKE DATA
            review: {
                loading: false,
                fields: fields_review,
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
