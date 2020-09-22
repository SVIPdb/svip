<template>
    <div class="container-fluid">
        <div v-if="checkInRole('reviewers')">
            <!-- ON REQUEST - CARD -->
            <NotificationCard v-if="REVIEW_ENABLED"
                :items="on_request.items"
                :fields="on_request.fields"
                :error="on_request.error"
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
            <OnRequestEntries
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
import NotificationCard from "@/components/widgets/curation/NotificationCard";
import EvidenceCard from "@/components/widgets/curation/EvidenceCard";
import { checkInRole } from "@/directives/access";

import to_be_curated from "@/data/curation/to_be_curated/items.json";
import fields_to_be_curated from "@/data/curation/to_be_curated/fields.json";

import to_be_discussed from "@/data/curation/to_be_discussed/items.json";
import fields_to_be_discussed from "@/data/curation/to_be_discussed/fields.json";

import nonsvip_variants from "@/data/curation/nonsvip_variants/items.json";
import fields_nonsvip_variants from "@/data/curation/nonsvip_variants/fields.json";
import OnRequestEntries from "@/components/widgets/curation/OnRequestEntries";

export default {
    name: "CurationDashboard",
    components: {
        OnRequestEntries,
        EvidenceCard,
        NotificationCard
    },
    data() {
        return {
            REVIEW_ENABLED: false, // temporary flag to hide review-related bits of the UI until they're ready

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
    methods: {
        checkInRole
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
