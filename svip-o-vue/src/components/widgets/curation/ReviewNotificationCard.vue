<template>
    <b-card class="shadow-sm mb-3" align="left" no-body>
        <b-card-header
            v-if="isCurator"
            class="p-1"
            :header-bg-variant="cardHeaderBg"
            :header-text-variant="cardTitleVariant"
            :class="cardCustomClass ? customClass : ''"
            :style="customBgColor && `background-color: ${customBgColor} !important`"
        >
            <div class="d-flex justify-content-between">
                <div class="p-2 font-weight-bold">
                    {{title}}

                    <b-button class="ml-3" size="sm" :variant="myFilter !== 'all' ? 'primary' : 'light'" @click="setCustomFilter(user.user_id)">
                        My curations
                        <b-badge pill :class="myFilter !== 'all' && 'bg-white text-dark'">{{ myCurations.length }}</b-badge>
                    </b-button>
                    <b-button class="ml-3" size="sm" :variant="myFilter === 'all' ? 'primary' : 'light'" @click="setCustomFilter('all')">
                        All curations
                        <b-badge pill :class="myFilter === 'all' && 'bg-white text-dark'">{{items.length}}</b-badge>
                    </b-button>

                    <FilterButtons v-if="cardFilterOption" class="ml-3" v-model="statusFilter" :items="[
                        { label: 'Not assigned', variant: 'danger' },
                        { label: 'Ongoing', variant: 'warning' },
                        { label: 'Complete', variant: 'success' },
                        { label: 'All', value: 'all', variant: 'info' }
                    ]" />
                </div>
                <div>
                    <b-input-group size="sm" class="p-1">
                        <b-form-input v-model="filter" placeholder="Type to Search"></b-form-input>
                        <b-input-group-append>
                            <b-button :variant="settings.buttonBg" size="sm" @click="filter = ''">Clear</b-button>
                        </b-input-group-append>
                    </b-input-group>
                </div>
            </div>
        </b-card-header>
        <b-card-header
            v-if="isReviewer"
            class="p-1"
            :header-bg-variant="cardHeaderBg"
            :header-text-variant="cardTitleVariant"
            :class="cardCustomClass ? customClass : ''"
            :style="customBgColor && `background-color: ${customBgColor} !important`"
        >
            <div class="d-flex justify-content-between">
                <div class="p-2 font-weight-bold">
                    {{title}}

                    <FilterButtons v-if="cardFilterOption" class="ml-3" v-model="statusFilter" :items="[
                        { label: '0 review', value: 0, variant: 'light' },
                        { label: '1 review', value: 1, variant: 'danger' },
                        { label: '2 reviews', value: 2, variant: 'warning' },
                        { label: '3 reviews', value: 3, variant: 'success' },
                        { label: 'All', value: 'all', variant: 'info' }
                    ]" />
                </div>
                <div>
                    <b-input-group size="sm" class="p-1">
                        <b-form-input v-model="filter" placeholder="Type to Search"></b-form-input>
                        <b-input-group-append>
                            <b-button :variant="settings.buttonBg" size="sm" @click="filter = ''">Clear</b-button>
                        </b-input-group-append>
                    </b-input-group>
                </div>
            </div>
        </b-card-header>

        <b-card-body v-if="isCurator" class="p-0">
            <b-table v-if="!error"
                class="mb-0"
                :items="filteredItems" :fields="fields"
                :filter="filter"
                :sort-by.sync="sortBy" :sort-desc="true"
                :busy="loading"
                :per-page="perPage" :current-page="currentPage"
                show-empty small hover :responsive="true"
            >
                <template v-slot:cell(gene_name)="data">
                    <b><router-link :to="`/gene/${data.item.gene_id}`" target="_blank">{{ data.value }}</router-link></b>
                </template>

                <template v-slot:cell(variant)="data">
                    <router-link :to="`/gene/${data.item.gene_id}/variant/${data.item.variant_id}`" target="_blank">{{ data.value }}</router-link>
                </template>

                <template v-slot:cell(hgvs)="data">
                    <p class="mb-0">{{data.value}}</p>
                </template>

                <template v-slot:cell(deadline)="row">
                    <p v-if="row.item.curated !== 'Complete'" :class="setFlagClass(row.item.days_left)+' m-0 p-0'">
                        <span class="font-weight-bold">{{ setLetter(row.item.days_left) }}</span>
                        ({{row.item.days_left}} days)
                    </p>
                </template>

                <template v-slot:cell(review_count)="data">
                    <b-badge :variant="setBadgeClass(data.value)">{{data.value}}</b-badge>
                </template>

                <template v-slot:cell(reviewed)="data">
                    <icon
                        v-for="(reviewer, index) in data.value"
                        v-bind:key="index"
                        v-b-popover.hover.top="reviewer.label"
                        :name="reviewer.value ? 'check' : 'times'"
                        :class="reviewer.value ? 'text-success mr-1' : 'text-danger mr-1'"
                    ></icon>
                </template>

                <template v-slot:cell(curator)="data">
                    <span v-for="(owner, idx) in data.value" :key="owner.name">
                        <span v-if="idx > 0">, </span>
                        <pass :name="abbreviatedName(owner.name)">
                            <b slot-scope="{ name }" v-b-tooltip.hover="name.name">{{ name.abbrev }}</b>
                        </pass>
                    </span>
                </template>

                <template v-slot:cell(action)="row">
                    <b-button v-access="'curators'" class="centered-icons" size="sm" style="width: 100px;" variant="info"
                        :to="{ name: 'annotate-variant', params: { gene_id: row.item.gene_id, variant_id: row.item.variant_id }}"
                        target="_blank"
                    >
                        <icon name="pen-alt" /> Curate
                    </b-button>
                </template>

                <template v-slot:cell(single_action)>
                    <icon class="mr-1" name="eye"/>
                </template>

                <template v-slot:table-busy>
                    <div class="text-center my-2">
                        <b-spinner class="align-middle" small></b-spinner>
                        <strong class="ml-1">Loading...</strong>
                    </div>
                </template>
            </b-table>
            <div v-else class="text-center text-muted font-italic m-3">
                <icon name="exclamation-triangle" scale="3" style="vertical-align: text-bottom; margin-bottom: 5px;" /><br />
                Loading this list failed, please try again later
            </div>

            <div v-if="slotsUsed" :class="`paginator-holster ${slotsUsed ? 'occupied' : ''}`">
                <slot name="extra_commands" />

                <b-pagination
                    v-if="totalRows > perPage"
                    v-model="currentPage"
                    :total-rows="totalRows"
                    :per-page="perPage"
                />
            </div>
        </b-card-body>

        <b-card-body v-if="isReviewer" class="p-0">
            <b-table
                class="mb-0"
                :items="filteredItems" :fields="fields"
                :filter="filter"
                :sort-by.sync="sortBy" :sort-desc="true"
                :busy="loading"
                :per-page="perPage" :current-page="currentPage"
                show-empty small hover
            >
                <template v-slot:cell(gene_name)="data">
                    <b><router-link :to="`/gene/${data.item.gene_id}`" target="_blank">{{ data.value }}</router-link></b>
                </template>

                <template v-slot:cell(variant)="data">
                    <router-link :to="`/gene/${data.item.gene_id}/variant/${data.item.variant_id}`" target="_blank">{{ data.value }}</router-link>
                </template>

                <template v-slot:cell(hgvs)="data">
                    <p class="mb-0">{{data.value}}</p>
                </template>

                <template v-slot:cell(deadline)="row">
                    <p v-if="row.item.curated !== 'Complete'" :class="setFlagClass(row.item.days_left)+' m-0 p-0'">
                        <span class="font-weight-bold">{{ setLetter(row.item.days_left) }}</span>
                        ({{row.item.days_left}} days)
                    </p>
                </template>

                <template v-slot:cell(status)="status_obj">
                    <span v-for="(review) in status_obj['item']['reviews']" :key="review">
                        <span v-if="review">
                            <b-icon style="color:blue;" class="h5 m-1" icon="check-square-fill"></b-icon>
                        </span>
                        <span v-else>
                            <b-icon style="color:red;" class="h5 m-1" icon="x-square-fill"></b-icon>
                        </span>
                    </span>

                    <span v-for="(index) in 3 - status_obj['item']['review_count']" :key="index">
                        <b-icon class="h5 m-1" icon="square"></b-icon>
                    </span>
                </template>

                <template v-slot:cell(reviewed)="data">
                    <icon
                        v-for="(reviewer, index) in data.value"
                        v-bind:key="index"
                        v-b-popover.hover.top="reviewer.label"
                        :name="reviewer.value ? 'check' : 'times'"
                        :class="reviewer.value ? 'text-success mr-1' : 'text-danger mr-1'"
                    ></icon>
                </template>

                <template v-slot:cell(curator)="data">
                    <span v-for="(owner, idx) in data.value" :key="owner.name">
                        <span v-if="idx > 0">, </span>
                        <pass :name="abbreviatedName(owner.name)">
                            <b slot-scope="{ name }" v-b-tooltip.hover="name.name">{{ name.abbrev }}</b>
                        </pass>
                    </span>
                </template>

                <template v-slot:cell(action)="row">
                    <!-- Ivo : replace v-access="'curators'" with v-access="'reviewers'" -->
                    <b-button class="centered-icons" size="sm" style="width: 100px;" variant="info"
                        :to="{ name: 'annotate-review', params: { gene_id: row.item.gene_id, variant_id: row.item.variant_id }}"
                        target="_blank"
                    >
                        <icon name="pen-alt" /> Review
                    </b-button>
                </template>

                <template v-slot:cell(single_action)>
                    <icon class="mr-1" name="eye"/>
                </template>

                <template v-slot:table-busy>
                    <div class="text-center my-2">
                        <b-spinner class="align-middle" small></b-spinner>
                        <strong class="ml-1">Loading...</strong>
                    </div>
                </template>
            </b-table>

            <div v-if="slotsUsed" :class="`paginator-holster ${slotsUsed ? 'occupied' : ''}`">
                <slot name="extra_commands" />

                <b-pagination
                    v-if="totalRows > perPage"
                    v-model="currentPage"
                    :total-rows="totalRows"
                    :per-page="perPage"
                />
            </div>
        </b-card-body>
    </b-card>
</template>

<script>/**
 * @group Curation
 * This Notification card allows to display a card which contains a table filled with samples waiting to be curated or reviewed
 */
/* eslint-disable */
import { abbreviatedName } from "@/utils";
import { mapGetters } from "vuex";
import FilterButtons from "@/components/widgets/curation/FilterButtons";
import { BIcon, BIconSquare, BIconCheckSquareFill, BIconXSquareFill } from 'bootstrap-vue';

export default {
    name: "ReviewNotificationCard",
    components: {
        FilterButtons,
        BIcon,
        BIconSquare,
        BIconCheckSquareFill,
        BIconXSquareFill,
    },
    props: {
        // The items of the table
        items: {
            type: Array,
            required: true,
            // The default value is an empty array: `[]`
            default: () => []
        },
        // The fields of the table
        fields: {
            type: Array,
            required: true,
            // The default value is an empty array: `[]`
            default: () => []
        },
        loading: {
            type: Boolean, default: false
        },
        error: {
            type: String, default: null
        },
        // The title of the card
        title: {
            type: String,
            required: true,
            // The default value is: `DEFAULT_TITLE`
            default: "DEFAULT_TITLE"
        },
        // The default column used to sort (Desc) the table
        defaultSortBy: {
            type: String,
            required: false,
            // The default value is: `id`
            default: "id"
        },
        // Override the card header background
        cardHeaderBg: {
            type: String,
            required: false,
            default: "light"
        },
        // Overrides cardHeaderBg
        customBgColor: {
            type: String, required: false
        },
        // Override the card title class
        cardTitleVariant: {
            type: String,
            required: false,
            default: "primary"
        },
        // On/Off filter options based on status
        cardFilterOption: {
            type: Boolean,
            required: false,
            default: false
        },
        // On/Off custom class for header background
        cardCustomClass: {
            type: Boolean,
            required: false,
            default: false
        },
        isCurator: {
            type: Boolean,
            required: false,
            default: false
        },
        isReviewer: {
            type: Boolean,
            required: false,
            default: false
        }
    },
    data() {
        return {
            customClass: "customClass",
            // Custom settings for the visual
            settings: {
                buttonBg: "primary"
            },
            // Needed parameters for the table
            sortBy: this.defaultSortBy,
            filter: null,
            myFilter: "all",
            statusFilter: "all",
            statusReviewFilter: "all",
            // Days left limits (Should be reviewed!)
            daysLeft: {
                min: 2,
                max: 14
            },
            // Mapping between status and classes
            curationStatus: {
                "Not assigned": "danger",
                Ongoing: "warning",
                Complete: "success"
            },

            // pagination controls
            perPage: 10,
            currentPage: 1
        };
    },
    methods: {
        abbreviatedName,
        /**
         * @vuese
         * Used to set up the correct flag class depending on the days left
         * @arg `Number` Days left
         */
        setFlagClass(days_left) {
            if (days_left <= this.daysLeft.min) {
                return "text-danger";
            } else if (days_left <= this.daysLeft.max) {
                return "text-warning";
            } else {
                return "text-success";
            }
        },
        /**
         * @vuese
         * Used to set up the correct priority depending on the days left
         * @arg `Number` Days left
         */
        setLetter(days_left) {
            if (days_left <= this.daysLeft.min) {
                return "H";
            } else if (days_left <= this.daysLeft.max) {
                return "M";
            } else {
                return "L";
            }
        },
        /**
         * @vuese
         * Used to set up the correct badge depending on the status
         * @arg `String` Curation status
         */
        setBadgeClass(status) {
            return this.curationStatus[status];
        },
        /**
         * @vuese
         * Used to use a specific filter
         * @arg `String` Filter
         */
        setCustomFilter(filter) {
            this.myFilter = filter;
        },
        /**
         * @vuese
         * Used to use a status filter
         * @arg `String` Status Filter
         */
        setStatusFilter(filter) {
            this.statusFilter = filter;
        },
        setStatusReviewFilter(filter) {
            this.statusReviewFilter = filter;
        },
        selectVariant() { // (checked, element)
            // console.log(`Checked is ${checked} and ID is ${element.id}`);
        }
    },
    watch: {
        myFilter(newVal, oldVal) {
            if (newVal !== oldVal) {
                this.currentPage = 1;
            }
        },
        statusFilter(newVal, oldVal) {
            if (newVal !== oldVal) {
                this.currentPage = 1;
            }
        }
    },
    computed: {
        ...mapGetters({
            user: "currentUser"
        }),
        // We are filtering items based on the two filters (custom and status)
        filteredItems() {
            let items = this.items;

            if (this.statusFilter !== "all") {
                items = items.filter(element => element.review_count === this.statusFilter);
            }

            if (this.myFilter !== "all") {
                return items.filter(x => x.curator.some(y => y.id === this.user.user_id));
            }
            else {
                return items;
            }
        },
        filteredReviewItems() {
            let items = this.items;

            if (this.statusReviewFilter !== "all") {
                items = items.filter(element => element.review_count === this.statusFilter);
            }
        },
        myCurations() {
            return this.items.filter(element => element.curator.some(x => x.id === this.user.user_id));
        },
        totalRows() {
            return this.items ? this.filteredItems.length : 0;
        },
        slotsUsed () {
            return !!this.$slots.extra_commands || (this.totalRows > this.perPage);
        }
    }
};
</script>

<style>
.customClass {
    background-color: #c40000 !important;
}
</style>
