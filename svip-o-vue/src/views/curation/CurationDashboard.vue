<template>
    <div class="container-fluid">
        <!-- ON REQUEST - CARD -->
        <notification-card
            :items="on_request"
            :fields="fields_on_request"
            sortBy="days_left"
            title="ON REQUEST"
            cardHeaderBg="secondary"
            cardTitleVariant="white"
            cardCustomClass
            cardFilterOption
        />
        <!-- TO BE CURATED - CARD -->
        <notification-card
            :items="to_be_curated"
            :fields="fields_to_be_curated"
            sortBy="days_left"
            title="TO BE CURATED"
            cardFilterOption
        />
        <!-- UNDER REVISION - CARD -->
        <notification-card
            :items="to_be_discussed"
            :fields="fields_to_be_discussed"
            sortBy="days_left"
            title="TO BE DISCUSSED"
        />
        <!-- NON SVIP VARIANTS - CARD -->
        <!--
        <notification-card
            :items="nonsvip_variants"
            :fields="fields_nonsvip_variants"
            title="NON SVIP VARIANTS"
        />
        -->
    </div>
</template>

<script>
import NotificationCard from "@/components/curation/widgets/NotificationCard";

// Manual import of fake data (FIXME: API)
import on_request from "@/data/curation/on_request/items.json";
import fields_on_request from "@/data/curation/on_request/fields.json";

import to_be_curated from "@/data/curation/to_be_curated/items.json";
import fields_to_be_curated from "@/data/curation/to_be_curated/fields.json";

import to_be_discussed from "@/data/curation/to_be_discussed/items.json";
import fields_to_be_discussed from "@/data/curation/to_be_discussed/fields.json";

import nonsvip_variants from "@/data/curation/nonsvip_variants/items.json";
import fields_nonsvip_variants from "@/data/curation/nonsvip_variants/fields.json";

export default {
    name: "CurationDashboard",
    components: {
        "notification-card": NotificationCard
    },
    data() {
        return {
            // ON REQUEST FAKE DATA
            on_request, // data
            fields_on_request, // columns

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
