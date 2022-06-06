<template>
    <b-card class="shadow-sm mb-3" align="left" no-body>
        <b-card-header
            v-if="hasHeader"
            class="p-1"
            :header-bg-variant="cardHeaderBg"
            :header-text-variant="cardTitleVariant"
        >
            <div class="d-flex justify-content-between">
                <div class="p-2 font-weight-bold">
                    {{headerTitle}}
                    <b-button-group class="ml-3">
                        <b-button size="sm" :variant="filterCurator ? 'primary' : 'light'" @click="filterCurator = true">{{ $t("My Curations")}}</b-button>
                        <b-button size="sm" :variant="!filterCurator ? 'primary' : 'light'" @click="filterCurator = false">{{ $t("All Curations")}}</b-button>
                    </b-button-group>

                    <FilterButtons v-if="cardFilterOption" class="ml-3" v-model="statusFilter" default-variant="light"
                        selected-variant="primary"
                        :items="[
                            { label: 'Draft', value: 'draft' },
                            { label: 'Saved', value: 'saved' },
                            { label: 'Submitted', value: 'submitted' },
                            { label: 'Unreviewed', value: 'unreviewed' },
                            { label: 'Reviewed', value: 'reviewed' },
                            { label: 'All', value: 'all' }
                        ]"
                    />
                </div>
                <div>
                    <b-input-group size="sm" class="p-1">
                        <b-form-input v-model="filter" debounce="300" placeholder="Type to Search"></b-form-input>
                        <b-input-group-append>
                            <b-button variant="primary" size="sm" @click="filter = ''">{{ $t("Clear")}}</b-button>
                        </b-input-group-append>
                    </b-input-group>
                </div>
            </div>
        </b-card-header>

        <b-card-body class="p-0">
            <PagedTable
                id="evidence_table"
                ref="paged_table"
                class="mb-0"
                :thead-class="`${!hasHeader && 'bg-primary text-light'} unwrappable-header`"
                primary-key="id"
                :tbody-tr-class="rowClass"
                :fields="fields"
                sort-by="created_on" sort-desc
                show-empty empty-text="There seems to be an error"
                :small="small"
                :external-search="filter"
                :apiUrl="apiUrl"
                :postMapper="colorCurationRows"
                :extraFilters="statusFilter !== 'all' ? { status: statusFilter } : null"
                :responsive="true"
            >

                <template v-slot:cell(variant__gene__symbol)="data">
                    <b><router-link :to="`/gene/${data.item.variant.gene.id}`">{{ data.item.variant.gene.symbol }}</router-link></b>
                </template>
                <template v-slot:cell(variant__name)="data">
                    <router-link :to="`/gene/${data.item.variant.gene.id}/variant/${data.item.variant.id}`">{{ data.item.variant.name }}</router-link>
                </template>

                <template v-slot:cell(extra_variants)="data">
                    <span v-if="data.value">
                        <span v-for="(variant, idx) in data.value" :key="variant.id">
                            <span v-if="idx > 0">, </span>
                            <router-link :to="`/gene/${variant.gene.id}/variant/${variant.id}`" target="_blank">{{ variant.description }}</router-link>
                        </span>
                    </span>
                </template>

                <template v-slot:cell(created_on)="data">{{ simpleDateTime(data.value).date }}</template>

                <template v-slot:cell(status)="data">
                  <span class="pub-status">
                    <icon :class="setClass(data.value)" :name="setIcon(data.value)" v-b-tooltip.hover :title="data.value"/>
                    {{ titleCase(data.value) }}
                  </span>
                </template>

                <template v-slot:cell(references)="data">
                    <VariomesLitPopover :pubmeta="{ pmid: data.value }"
                        :variant="data.item.variant && data.item.variant.name"
                        :gene="data.item.variant && data.item.variant.gene.symbol"
                        :disease="data.item.disease && data.item.disease.name"
                    />
                </template>

                <template v-slot:cell(created_on)="data">
                    <DateTimeField :datetime="data.value" />
                </template>

                <template v-slot:cell(last_modified)="data">
                    <DateTimeField :datetime="data.value" />
                </template>

                <template v-slot:cell(owner_name)="data">
                    <pass :name="abbreviatedName(data.value)">
                        <span slot-scope="{ name }" v-b-tooltip.hover="name.name">{{ name.abbrev }}</span>
                    </pass>
                </template>

                <template v-slot:cell(action)="data">
                    <span class="action-tray">
                        <b-button v-if="data.item.status !== 'submitted'"
                            target="_blank"
                            class="centered-icons"
                            size="sm"
                            :href="editEntryURL(data.item)"
                            style="min-width: 75px;"
                        >
                            <icon name="pen-alt" />{{ $t("Edit")}}
                        </b-button>
                        <b-button v-else
                            target="_blank"
                            class="centered-icons"
                            size="sm"
                            :href="editEntryURL(data.item)"
                            style="min-width: 75px;"
                        >
                            <icon name="eye" />{{ $t("View")}}
                        </b-button>

                        <b-button
                            class="btn-danger"
                            :disabled="data.item.status === 'submitted'"
                            v-b-tooltip="'Delete'"
                            size="sm"
                            @click="deleteEntry(data.item.id)"
                        >
                            <icon name="trash" label="Delete" />
                        </b-button>
                        <b-button
                            class="btn-info"
                            v-b-tooltip="'History'"
                            size="sm"
                            @click="showHistory(data.item.id)"
                        >
                            <icon name="history" label="History" />
                        </b-button>
                    </span>
                    <b-navbar-text class="fixed-bottom submitted-bar" align="center" v-if="already_submitted">
                    {{ $t("THE CURATIONS FOR THIS VARIANT HAVE ALREADY BEEN SUBMITTED.")}}
                </b-navbar-text>
                </template>

                <template v-slot:extra_commands>
                    <div style="margin-bottom: 10px; margin-right: 10px;">
                        <b-button variant="info" @click="submitAll" style="height: 34px;" :disabled="already_submitted">
                            {{ $t("Submit to review")}}
                        </b-button>
                    </div>
                </template>
            </PagedTable>

            <b-modal
                ref="history-modal"
                hide-footer
                static
                lazy
                scrollable
                size="lg"
                :title="`Entry #${history_entry_id} History`"
            >
                <div>
                    <EvidenceHistory v-if="history_entry_id" :entry_id="history_entry_id" />
                    <div v-else>{{ $t("Error: no curation entry selected")}}</div>
                </div>
            </b-modal>
        </b-card-body>
    </b-card>
</template>

<script>
// import fields from "@/data/curation/evidence/fields.js";
import { HTTP } from "@/router/http";
import PagedTable from "@/components/widgets/PagedTable";
import VariomesLitPopover from "@/components/widgets/VariomesLitPopover";
import BroadcastChannel from "broadcast-channel";
import { abbreviatedName, simpleDateTime, titleCase } from "@/utils";
import EvidenceHistory from "@/components/widgets/curation/EvidenceHistory";
import { mapGetters } from "vuex";
import dayjs from 'dayjs';
import ulog from 'ulog';
import FilterButtons from "@/components/widgets/curation/FilterButtons";
import router from '@/router';

const log = ulog('Curation:EvidenceCard');

const DateTimeField = {
    props: {
        datetime: { required: true }
    },
    render() {
        const fullDate = dayjs(this.datetime).format("h:mm a");
        const parsed = simpleDateTime(this.datetime);

        return (
            <span v-b-tooltip={fullDate}>{parsed.date}</span>
        );
    }
};

// used by the citations browser
const full_fields = [
    //{
    //    key: "status",
    //    label: "Status",
    //    sortable: true
    //},
    {
        key: "id",
        label: "ID",
        sortable: true
    },
    {
        key: "references",
        label: "Reference",
        sortable: true
    },
    {
        key: "type_of_evidence",
        label: "Type of evidence",
        sortable: true
    },
    {
        key: "disease__name",
        label: "Disease",
        sortable: true,
        formatter: (x, k, obj) => obj.disease && obj.disease.name
    },
    {
        key: "drugs",
        label: "Drugs",
        sortable: true,
        formatter: x => x.join(", ")
    },
    {
        key: "effect",
        label: "Effect",
        sortable: true
    },
    {
        key: "tier_level_criteria",
        label: "Tier criteria",
        sortable: false
    },
    {
        key: "tier_level",
        label: "Tier level",
        sortable: true
    },
    {
        key: `short_escat_score`,
        label: "ESCAT score",
        sortable: true
    },
    {
        key: "extra_variants",
        label: "Other Variants",
        sortable: true
    },
    {
        key: "owner_name",
        label: "Curator",
        sortable: true
    },
    {
        key: "created_on",
        label: "Created on",
        sortable: true
    },
    {
        key: "last_modified",
        label: "Modified",
        sortable: true
    },
    {
        key: "action",
        label: "",
        sortable: false
    }
];

// used by the queue of pending/in progress/complete citations
const dashboard_fields = [
    {
        key: "variant__gene__symbol",
        label: "Gene",
        sortable: true,
        formatter: (x, k, obj) => obj.variant.gene.symbol
    },
    {
        key: "variant__name",
        label: "Variant",
        sortable: true,
        formatter: (x, k, obj) => obj.variant.name
    },
    {
        key: "disease__name",
        label: "Disease",
        sortable: true,
        formatter: (x, k, obj) => obj.disease && obj.disease.name
    },
    {
        key: "references",
        label: "Reference",
        sortable: true
    },
    {
        key: "id",
        label: "ID",
        sortable: true
    },
    {
        key: "type_of_evidence",
        label: "Type of evidence",
        sortable: true
    },
    {
        key: "status",
        label: "Status",
        sortable: true
    },
    {
        key: "owner_name",
        label: "Curator",
        sortable: true
    },
    {
        key: "created_on",
        label: "Created",
        sortable: true
    },
    {
        key: "last_modified",
        label: "Modified",
        sortable: true
    },
    {
        key: "action",
        label: "",
        sortable: false
    }
];

export default {
    name: "EvidenceCard",
    components: { EvidenceHistory, VariomesLitPopover, PagedTable, DateTimeField, FilterButtons },
    props: {
        variant: { type: Object, required: false },
        disease_id: { type: Number, required: false },
        isDashboard: { type: Boolean, required: false, default: false },
        includeGeneVar: { type: Boolean, required: false, default: false },
        small: { type: Boolean, required: false, default: false },
        isSubmittable: { type: Boolean, required: false, default: false },
        onlySubmitted: { type: Boolean, required: false, default: false },
        notSubmitted: { type: Boolean, required: false, default: false },
        hasHeader: { type: Boolean, default: false },
        headerTitle: { type: String, required: false, default: "Curation Entries" },
        cardHeaderBg: { type: String, required: false, default: "light" },
        cardTitleVariant: { type: String, required: false, default: "primary" },
        cardFilterOption: { type: Boolean, default: true },
    },
    data() {
        return {
            channel: new BroadcastChannel("curation-update"),
            filterCurator: false,
            history_entry_id: null,
            filter: null,
            selected: {},
            statusFilter: 'all',
            already_submitted: false
        };
    },
    created() {
        this.channel.onmessage = () => {
            if (this.$refs.paged_table) {
                this.$refs.paged_table.refresh();
            }
        };

        if ([
            '0_review', 
            '1_review', 
            '2_reviews', 
            'conflicting_reviews', 
            'to_review_again', 
            'on_hold', 
            'fully_reviewed'
        ].includes(this.variant.stage)) {
            this.already_submitted = true
        }
    },
    computed: {
        ...mapGetters(["userID"]),
        fields() {
            let fields = this.isDashboard ? dashboard_fields : full_fields;

            // add the submit box as an extra field if this is submittable
            if (this.isSubmittable) {
                fields = [
                    {
                        key: "submit_box",
                        label: "",
                        sortable: false
                    },
                    ...fields
                ];
            }

            if (this.includeGeneVar) {
                fields = [
                    {
                        key: "variant__gene__symbol",
                        label: "Gene",
                        sortable: true,
                        formatter: (x, k, obj) => obj.variant.gene.symbol
                    },
                    {
                        key: "variant__name",
                        label: "Variant",
                        sortable: true,
                        formatter: (x, k, obj) => obj.variant.name
                    },
                    ...fields
                ];
            }

            return fields;
        },
        disease() {
            if (!this.variant || !this.disease_id || !this.variant.svip_data) {
                return null;
            }

            return this.variant.svip_data.diseases.find(
                element => element.disease_id === this.disease_id
            );
        },
        apiUrl() {
            const params = [
                this.variant && `variant_ref=${this.variant.id}`,
                // this.disease_id && `disease=${this.disease_id}`,
                this.filterCurator && `owner=${this.userID}`,
                // FIXME: these two are mutually exclusive
                this.onlySubmitted && `status=submitted`,
                this.notSubmitted && `status_ne=submitted`
            ].filter(x => x);

            return `/curation_entries${params ? "?" + params.join("&") : ""}`;
        },
        variomesParams() {
            return {
                variant: this.variant && this.variant.name,
                gene: this.variant && this.variant.gene.symbol,
                disease: this.disease && this.disease.name
            };
        },
        selectedCount() {
            return Object.keys(this.selected).length;
        }
    },
    methods: {
        titleCase,
        simpleDateTime,
        abbreviatedName,
        rowClass(item) {
            if (!item) return;
            if (item.stats === "completed") return "table-light";
        },
        setClass(status) {
            if (status === "complete") {
                return "text-success";
            } else if (status === "review") {
                return "text-info";
            } else {
                return "text-primary";
            }
        },
        setIcon(status) {
            if (status === "complete") {
                return "check";
            } else if (status === "review" || status === "submitted") {
                return "tasks";
            } else {
                return "pen-alt";
            }
        },
        toggleSelected(id, isChecked) {
            if (!isChecked) {
                this.$delete(this.selected, id);
            }
            else {
                this.$set(this.selected, id, true);
            }
        },
        editEntryURL(entry) {
            return `/curation/entry/${entry.id}`;
        },
        deleteEntry(entry_id) {
            if (confirm("Are you sure that you want to delete this entry?")) {
                HTTP.delete(`/curation_entries/${entry_id}`)
                    .then(() => {
                        this.channel.postMessage(`Deleted ID ${entry_id}`);
                        this.$snotify.info("Entry deleted!");
                        this.$refs.paged_table.refresh();
                    })
                    .catch(() => {
                        this.$snotify.error("Failed to delete entry");
                    });
            }
        },
        submitRequest() {
            const entryIDs = Object.keys(this.selected).join(",");
            // TODO: set the status of all the selected entries to 'submitted'
            HTTP.post(`/curation_entries/bulk_submit?items=${entryIDs}`)
                .then(() => {

                    // add request to change the status of the variant

                    router.push({
                        name: "submit-curation"
                    });
                })
                .catch((err) => {
                    this.$snotify.error("Failed to submit entries");
                    log.warn(err);
                });
        },
        submitAll() {
            const prompt = "Are you sure that you want to submit the entries of this variant?\n\nYou will no longer be able to edit your entries after submitting them!"
            if (confirm(prompt)) {
                const params = {var_id : this.variant.id}
                HTTP.post(`/curation_ids`, params)
                    .then((response) => {
                        this.selected = response.data
                        this.submitRequest();
                    })
                    .catch((err) => {
                        log.warn(err);
                    })
            }
        },
        showHistory(entry_id) {
            this.$refs["history-modal"].show();
            this.history_entry_id = entry_id;
        },
        colorCurationRows(data) {
            // maps each row to a color variant based on its status (e.g., drafts are gray)
            return data.map(x => {
                if (x.status === "draft") {
                    x._rowVariant = "light";
                }
                return x;
            });
        }
    }
};
</script>

<style scoped>
.pub-status {
    justify-content: flex-start;
    display: flex;
    align-items: center;
}
.pub-status > .fa-icon {
    margin-right: 0.4rem;
}

.action-tray {
    display: flex;
    justify-content: flex-end;
}
.action-tray .btn {
    margin-left: 5px;
    margin-bottom: 5px;
    display: flex;
    align-items: center;
    justify-content: center;
}

#evidence_table >>> .table {
    margin-bottom: 0;
}

.submitted-bar {
    background-color: rgb(194, 45, 0);
    color: white;
    font-weight: bold;
    text-align: center;
    padding: 0.4rem;
}
</style>
