<template>
    <b-card class="shadow-sm mb-3" align="left" no-body>
        <b-card-header
            v-if="hasHeader"
            class="p-1"
            :header-bg-variant="cardHeaderBg"
            :header-text-variant="cardTitleVariant">
            <div class="d-flex justify-content-between">
                <div class="p-2 font-weight-bold">
                    {{ headerTitle }}
                    <b-button-group class="ml-3">
                        <b-button
                            size="sm"
                            :variant="filterOwner ? 'primary' : 'light'"
                            @click="filterOwner = true">
                            My Submissions
                        </b-button>
                        <b-button
                            size="sm"
                            :variant="!filterOwner ? 'primary' : 'light'"
                            @click="filterOwner = false">
                            All Submissions
                        </b-button>
                    </b-button-group>

                    <FilterButtons
                        v-if="cardFilterOption"
                        class="ml-3"
                        v-model="statusFilter"
                        default-variant="light"
                        selected-variant="primary"
                        :items="statusItems" />
                </div>
                <div>
                    <b-input-group size="sm" class="p-1">
                        <b-form-input
                            v-model="filter"
                            debounce="300"
                            placeholder="Type to Search"></b-form-input>
                        <b-input-group-append>
                            <b-button variant="primary" size="sm" @click="filter = ''">Clear</b-button>
                        </b-input-group-append>
                    </b-input-group>
                </div>
            </div>
        </b-card-header>

        <b-card-body class="p-0">
            <PagedTable
                id="submission_queue"
                ref="paged_table"
                class="mb-0"
                :thead-class="`${!hasHeader && 'bg-primary text-light'} unwrappable-header`"
                primary-key="id"
                :tbody-tr-class="rowClass"
                :fields="fields"
                sort-by="created_on"
                sort-desc
                show-empty
                empty-text="There seems to be an error"
                :small="small"
                :external-search="filter"
                :apiUrl="apiUrl"
                :extraFilters="statusFilter !== 'all' ? {status: statusFilter} : null"
                :responsive="true"
                @data-loaded="
                    data => {
                        $emit('data-loaded', data);
                    }
                ">
                <template v-slot:cell(action)="entry">
                    <row-expander v-if="entry.item.status !== 'pending'" :row="entry" />
                    &nbsp;
                </template>

                <template v-slot:cell(status)="data">
                    <b-badge :variant="variantForStatus(data.item.status)">
                        {{ data.item.status }}
                    </b-badge>
                </template>

                <template v-slot:cell(canonical_only)="data">
                    <b-icon-check-circle-fill v-if="data.value" variant="success" />
                    <b-icon-circle v-else variant="secondary" />
                </template>

                <template v-slot:cell(for_curation_request)="data">
                    <b-icon-check-circle-fill v-if="data.value" variant="success" />
                    <b-icon-circle v-else variant="secondary" />
                </template>

                <template v-slot:row-details="entry">
                    <div v-if="entry.item.status !== 'error'" class="sample-subtable tumor-subtable">
                        <h6>Resulting Variant(s):</h6>
                        <b-table
                            class="shadow-sm m-0"
                            :items="entry.item.resulting_variants"
                            :fields="resulting_variant_fields">
                            <template v-slot:cell(description)="data">
                                <router-link
                                    :to="`/gene/${data.item.gene.id}/variant/${data.item.id}`"
                                    target="_blank">
                                    {{ data.value }}
                                </router-link>
                            </template>
                        </b-table>
                    </div>
                    <div v-else class="failure-output">
                        <b>Error:</b>
                        <div>{{ entry.item.error_msg }}</div>
                    </div>
                </template>
            </PagedTable>
        </b-card-body>
    </b-card>
</template>

<script>
import {BIconCheckCircleFill, BIconCircle} from 'bootstrap-vue';
import PagedTable from '@/components/widgets/PagedTable';
import FilterButtons from '@/components/widgets/curation/FilterButtons';
import {mapGetters} from 'vuex';
import BroadcastChannel from 'broadcast-channel';
import {combinedDateTime} from '@/utils';

export default {
    name: 'SubmissionQueue',
    components: {
        FilterButtons,
        PagedTable,
        BIconCheckCircleFill,
        BIconCircle,
    },
    props: {
        variant: {type: Object, required: false},
        disease_id: {type: Number, required: false},
        isDashboard: {type: Boolean, required: false, default: false},
        includeGeneVar: {type: Boolean, required: false, default: false},
        small: {type: Boolean, required: false, default: false},
        isSubmittable: {type: Boolean, required: false, default: false},
        onlySubmitted: {type: Boolean, required: false, default: false},
        notSubmitted: {type: Boolean, required: false, default: false},
        hasHeader: {type: Boolean, default: false},
        headerTitle: {
            type: String,
            required: false,
            default: 'Submitted Variants',
        },
        cardHeaderBg: {type: String, required: false, default: 'light'},
        cardTitleVariant: {type: String, required: false, default: 'primary'},
        cardFilterOption: {type: Boolean, default: true},
    },
    data() {
        return {
            statusFilter: 'all',
            filter: null,
            filterOwner: false,

            // listens for submission updates
            channel: new BroadcastChannel('submission-update'),
        };
    },
    created() {
        this.channel.onmessage = () => {
            if (this.$refs.paged_table) {
                this.$refs.paged_table.refresh();
            }
        };
    },
    computed: {
        ...mapGetters(['userID']),
        apiUrl() {
            const params = [
                // this.disease_id && `disease=${this.disease_id}`,
                this.filterOwner && `owner=${this.userID}`,
                // FIXME: these two are mutually exclusive
                this.onlySubmitted && `status=submitted`,
                this.notSubmitted && `status_ne=submitted`,
            ].filter(x => x);

            return `/submitted_variants${params ? '?' + params.join('&') : ''}`;
        },
        statusItems() {
            return [
                {label: 'Pending', value: 'pending', variant: 'warning'},
                {label: 'Completed', value: 'completed', variant: 'success'},
                {label: 'Error', value: 'error', variant: 'danger'},
                {label: 'All', value: 'all'},
            ];
        },
        fields() {
            return [
                {key: 'action', label: ''},
                {key: 'id', label: 'ID'},
                {
                    key: 'created_on',
                    label: 'Created On',
                    sortable: true,
                    formatter: v => combinedDateTime(v),
                },
                {key: 'owner_name', label: 'Owner', sortable: true},
                {key: 'description', label: 'Description', sortable: true},
                {key: 'status', label: 'Status', sortable: true},
                {key: 'canonical_only', label: 'Canonical', sortable: true},
                {
                    key: 'for_curation_request',
                    label: 'For Curation',
                    sortable: true,
                },
                {
                    key: 'batch',
                    label: 'Batch ID',
                    sortable: true,
                    formatter: v => v || '---',
                },
                {
                    key: 'resulting_variants',
                    label: 'Variants',
                    sortable: true,
                    formatter: v => (v !== null ? v.length : '---'),
                },
            ];
        },
        resulting_variant_fields() {
            return [
                {key: 'id', label: 'ID'},
                {key: 'description', label: 'Variant'},
                {key: 'hgvs_c', label: 'HGVS.c'},
            ];
        },
    },
    methods: {
        combinedDateTime,
        rowClass(item) {
            if (!item) return;
            if (item.stats === 'completed') return 'table-light';
        },
        variantForStatus(status) {
            const found = this.statusItems.find(x => x.value === status);
            return found ? found.variant : 'secondary';
        },
    },
};
</script>

<style scoped>
.failure-output {
    padding: 10px;
    box-shadow: inset 0 2px 2px rgba(0, 0, 0, 0.2);
    background-color: #efefef;

    overflow-x: scroll;
    white-space: pre;
    font-family: monospace;
}
</style>
