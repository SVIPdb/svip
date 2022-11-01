<template>
    <b-card class="shadow-sm mb-3" align="left" no-body>
        <b-card-header
            v-if="isReviewer"
            class="p-1"
            :header-bg-variant="cardHeaderBg"
            :header-text-variant="cardTitleVariant"
            :style="customBgColor && `background-color: ${customBgColor} !important`">
            <div class="d-flex justify-content-between flex-wrap">
                <div class="d-flex justify-content-between align-items-center">
                    <div class="p-2">
                        <span class="font-weight-bold">
                            {{ title }}
                        </span>

                        <FilterButtons
                            v-if="cardFilterOption"
                            class="ml-3"
                            v-model="statusReviewFilter"
                            :items="[
                                {
                                    label: 'New',
                                    value: 'new',
                                    variant: 'info',
                                },
                                {
                                    label: 'In process',
                                    value: 'process',
                                    variant: 'warning',
                                },

                                {
                                    label: 'On-hold',
                                    value: 'conflicting',
                                    variant: 'danger',
                                },
                                {
                                    label: 'Approved',
                                    value: 'finished',
                                    variant: 'success',
                                },
                                {
                                    label: 'All',
                                    value: 'all',
                                    variant: 'secondary',
                                },
                            ]" />
                    </div>
                    <b-form-checkbox
                        v-if="isReviewer"
                        class="ml-4"
                        id="checkbox-1"
                        v-model="statusMyReview"
                        name="checkbox-1"
                        value="my"
                        unchecked-value="all">
                        My reviews
                    </b-form-checkbox>
                </div>

                <div>
                    <b-input-group size="sm" class="p-1">
                        <b-form-input v-model="filter" placeholder="Type to Search"></b-form-input>
                        <b-input-group-append>
                            <b-button :variant="settings.buttonBg" size="sm" @click="filter = ''">
                                Clear
                            </b-button>
                        </b-input-group-append>
                    </b-input-group>
                </div>
            </div>
        </b-card-header>

        <b-card-body v-if="isReviewer" class="p-0">
            <b-table
                class="mb-0"
                :items="filteredReviewItems"
                :fields="fields"
                :filter="filter"
                :sort-by.sync="sortBy"
                :sort-desc="true"
                :busy="loading"
                :per-page="perPage"
                :current-page="currentPage"
                show-empty
                small
                hover>
                <template v-slot:cell(gene)="data">
                    <b>
                        <router-link :to="`/gene/${data.item.gene.id}`" target="_blank">
                            {{ data.item.gene.symbol }}
                        </router-link>
                    </b>
                </template>

                <template v-slot:cell(variant)="data">
                    <router-link
                        :to="`/gene/${data.item.gene.id}/variant/${data.item.variant.id}`"
                        target="_blank">
                        {{ data.item.variant.name }}
                    </router-link>
                </template>

                <template v-slot:cell(hgvs)="data">
                    <p class="mb-0">{{ data.value }}</p>
                </template>

                <template v-slot:cell(diseases)="data">
                    <p class="mb-0" v-for="(disease, idx) in data.item.diseases" :key="`${disease}  ${idx}`">
                        {{ disease }}
                    </p>
                </template>

                <template v-slot:cell(status)="status_obj">
                    <span
                        v-for="(review, i) in status_obj['item']['reviews_summary']"
                        :key="i + ' review_status'">
                        <span>
                            <b-icon
                                :style="{
                                    color: `${displayColor(review, status_obj['item']['draft_summary'][i])}`,
                                }"
                                class="h5 m-1"
                                :icon="displayIcon(review)"
                                :class="{
                                    notOwn: !(user.user_id === status_obj['item']['reviewers'][i]),
                                }"></b-icon>
                        </span>
                    </span>

                    <span
                        v-for="index in 3 - status_obj['item']['review_count']"
                        :key="index + Math.random()">
                        <b-icon class="h5 m-1" icon="square"></b-icon>
                    </span>
                </template>

                <template v-slot:cell(curators)="data">
                    <span v-for="(owner, idx) in data.item.curators" :key="owner + '_' + idx">
                        <span v-if="idx > 0">,</span>
                        <pass :name="abbreviatedName(owner)">
                            <b slot-scope="{name}" v-b-tooltip.hover="name.name">
                                {{ name.abbrev }}
                            </b>
                        </pass>
                    </span>
                </template>

                <template v-slot:cell(action)="data">
                    <b-button
                        :disabled="['approved', 'unapproved', 'on-hold'].includes(data.item.stage)"
                        class="centered-icons reviewBtn"
                        size="sm"
                        style="width: 140px"
                        variant="info"
                        :to="{
                            name: 'annotate-review',
                            params: {
                                gene_id: data.item.gene.id,
                                variant_id: data.item.variant.id,
                            },
                        }"
                        target="_blank">
                        <icon name="pen-alt" />
                        {{ `${data.item.stage === 'reannotated' ? 'Second review' : 'Review'} ` }}
                    </b-button>
                </template>

                <template v-slot:cell(single_action)>
                    <icon class="mr-1" name="eye" />
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
                    :per-page="perPage" />
            </div>
        </b-card-body>
    </b-card>
</template>

<script>
/**
 * @group Curation
 * This Notification card allows to display a card which contains a table filled with samples waiting to be curated or reviewed
 */
/* eslint-disable */
import {abbreviatedName} from '@/utils';
import {mapGetters} from 'vuex';
import FilterButtons from '@/components/widgets/curation/FilterButtons';
import {BIcon, BIconCheckSquareFill, BIconSquare, BIconXSquareFill} from 'bootstrap-vue';

export default {
    name: 'ReviewNotificationCardNew',
    components: {
        FilterButtons,
        BIcon,
        BIconSquare,
        BIconCheckSquareFill,
        BIconXSquareFill,
    },
    props: {
        items: {
            type: Array,
            required: true,
            default: () => [],
        },
        fields: {
            type: Array,
            required: true,
            default: () => [],
        },
        loading: {
            type: Boolean,
            default: false,
        },
        error: {
            type: String,
            default: null,
        },
        title: {
            type: String,
            required: true,
            default: 'DEFAULT_TITLE',
        },
        // The default column used to sort (Desc) the table
        defaultSortBy: {
            type: String,
            required: false,
            default: 'id',
        },
        // Override the card header background
        cardHeaderBg: {
            type: String,
            required: false,
            default: 'light',
        },
        // Overrides cardHeaderBg
        customBgColor: {
            type: String,
            required: false,
        },
        // Override the card title class
        cardTitleVariant: {
            type: String,
            required: false,
            default: 'primary',
        },
        // On/Off filter options based on status
        cardFilterOption: {
            type: Boolean,
            required: false,
            default: false,
        },
        isReviewer: {
            type: Boolean,
            required: false,
            default: false,
        },
    },
    data() {
        return {
            review_cycle: 'First review cycle',
            // Custom settings for the visual
            settings: {
                buttonBg: 'primary',
            },
            // Needed parameters for the table
            sortBy: this.defaultSortBy,
            filter: null,
            statusReviewFilter: 'all',
            statusMyReview: 'all',
            // Days left limits (Should be reviewed!)
            daysLeft: {
                min: 2,
                max: 14,
            },
            // Mapping between status and classes
            curationStatus: {
                'Not assigned': 'danger',
                'Ongoing': 'warning',
                'Complete': 'success',
            },

            // pagination controls
            perPage: 10,
            currentPage: 1,
        };
    },
    methods: {
        displayColor(review, draft_status) {
            if (draft_status) {
                return 'gray';
            } else {
                return review ? 'blue' : 'red';
            }
        },
        displayIcon(review) {
            return review ? 'check-square-fill' : 'x-square-fill';
        },
        abbreviatedName,
        /**
         * @vuese
         * Used to set up the correct flag class depending on the days left
         * @arg `Number` Days left
         */
        setFlagClass(days_left) {
            if (days_left <= this.daysLeft.min) {
                return 'text-danger';
            } else if (days_left <= this.daysLeft.max) {
                return 'text-warning';
            } else {
                return 'text-success';
            }
        },

        setStatusReviewFilter(filter) {
            this.statusReviewFilter = filter;
        },
    },
    watch: {
        statusReviewFilter(newVal, oldVal) {
            if (newVal !== oldVal) {
                this.currentPage = 1;
            }
        },
        statusMyReview(newVal, oldVal) {
            if (newVal !== oldVal) {
                this.currentPage = 1;
            }
        },
    },
    computed: {
        ...mapGetters({
            user: 'currentUser',
        }),

        filteredReviewItems() {
            let items =
                this.statusMyReview === 'my'
                    ? this.items.filter(item => item.reviewers.includes(this.user.user_id))
                    : this.items;

            switch (this.statusReviewFilter) {
                case 'process':
                    items = items.filter(
                        item =>
                            (item.review_count < 3 && item.review_count > 0) ||
                            (item.review_count <= 3 &&
                                item.draft_summary &&
                                item.draft_summary.includes(true))
                    );
                    break;
                case 'new':
                    items = items.filter(item => item.review_count === 0);
                    break;
                case 'finished':
                    items = items.filter(item => {
                        return (
                            item.review_count === 3 && item.reviews_summary.reduce((a, b) => a + b, 0) === 3
                        );
                    });
                    break;
                case 'conflicting':
                    items = items.filter(item => {
                        return item.stage === 'unapproved';
                    });
            }

            return items;
        },

        totalRows() {
            return this.items ? this.items.length : 0; // return this.items ? this.filteredItems.length : 0;
        },
        slotsUsed() {
            return !!this.$slots.extra_commands || this.totalRows > this.perPage;
        },
        review_cycle_title() {
            return 'First review cycle';
        },
    },
};
</script>

<style>
.notOwn {
    opacity: 0.4;
}

reviewBtn {
    width: 100px;
}
</style>
