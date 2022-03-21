<template>
    <div class="container-fluid">
        <div><!-- Ivo - original : <div v-if="checkInRole('reviewers')"> -->
            <!-- ON REQUEST - CARD -->
            <ReviewNotificationCard v-if="REVIEW_ENABLED"
                :items="reviews" :fields="review.fields" :loading="review.loading"
                :isReviewer="true"
                title="REVIEWS"
                :error="on_request.error"
                defaultSortBy="days_left"
                cardHeaderBg="secondary"
                customBgColor="#1f608f"
                cardTitleVariant="white"
                cardFilterOption
            />
        </div>

        <!-- Ivo - original : <div v-else-if="checkInRole('curators')"> -->
        <div v-if="checkInRole('curators') || checkInRole('reviewers')">
            <!-- TBC: request queue -->
            <OnRequestEntries
                :isCurator="checkInRole('curators')"
                :isReviewer="checkInRole('reviewers')"
                defaultSortBy="days_left"
                title="ON REQUEST"
                cardHeaderBg="secondary"
                cardTitleVariant="white"
                cardCustomClass
                cardFilterOption
                @itemsloaded="onRequestItemsLoaded"
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
            <p>You may only see the curation tables if you are a curator.</p>
            <router-link to="/">return to homepage</router-link>
        </div>
    </div>
</template>

<script>
import {HTTP} from "@/router/http";
import ReviewNotificationCard from "@/components/widgets/curation/ReviewNotificationCard";
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
import OnRequestEntries from "@/components/widgets/curation/OnRequestEntries";

import {
    abbreviatedName
} from "@/utils";

export default {
    name: "CurationDashboard",
    components: {
        OnRequestEntries,
        EvidenceCard,
        ReviewNotificationCard
    },
    data() {
        return {
            // Ivo - orignial : REVIEW_ENABLED: false,
            REVIEW_ENABLED: true, // temporary flag to hide review-related bits of the UI until they're ready

            // ON REQUEST
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

            reviews: [],

            // TO BE CURATED FAKE DATA
            to_be_curated, // data
            fields_to_be_curated, // columns

            // TO BE DISCUSSED FAKE DATA
            to_be_discussed, // data
            fields_to_be_discussed, // columns

            // NON SVIP VARIANTS FAKE DATA
            nonsvip_variants, // data
            fields_nonsvip_variants, // columns
        };
    },
    mounted() {
        console.log('flag')
        HTTP.get(`/dashboard_reviews`).then((response) => {
            console.log("REVIEWS :")
            console.log(response.data.reviews
            )
            this.reviews = response.data.reviews
        });
    },
    methods: {
        checkInRole,
        onRequestItemsLoaded(items) {
            this.on_request.items = items;
            this.on_request.loading = false;
        },
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
