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
                        <b-button
                            size="sm"
                            :variant="filterCurator ? 'primary' : 'light'"
                            @click="filterCurator = true"
                        >My Curations</b-button>
                        <b-button
                            size="sm"
                            :variant="!filterCurator ? 'primary' : 'light'"
                            @click="filterCurator = false"
                        >All Curations</b-button>
                    </b-button-group>
                </div>
                <div>
                    <b-input-group size="sm" class="p-1">
                        <b-form-input v-model="filter" placeholder="Type to Search"></b-form-input>
                        <b-input-group-append>
                            <b-button variant="primary" size="sm" @click="filter = ''">Clear</b-button>
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
                sort-by="created_on"
                sort-desc
                show-empty
                empty-text="There seems to be an error"
                :external-search="filter"
                :apiUrl="apiUrl"
                :postMapper="colorCurationRows"
            >
                <template v-slot:cell(submit_box)="data">
                    <input type="checkbox" v-if="data.item.status === 'draft' || data.item.status === 'saved'"
                        :disabled="data.item.status === 'draft'"
                        :value="selected[data.item.id]" @input="toggleSelected(data.item.id, $event.target.checked)"
                        aria-label="select"
                    />
                </template>

                <template v-slot:cell(variant__gene__symbol)="data">
                    <b><router-link :to="`/gene/${data.item.variant.gene.id}`">{{ data.item.variant.gene.symbol }}</router-link></b>
                </template>
                <template v-slot:cell(variant__name)="data">
                    <router-link :to="`/gene/${data.item.variant.gene.id}/variant/${data.item.variant.id}`">{{ data.item.variant.name }}</router-link>
                </template>
                <template v-slot:cell(disease__name)="data">
                    <router-link
                        :to="`/curation/gene/${data.item.variant.gene.id}/variant/${data.item.variant.id}/disease/${data.item.disease.id}`"
                        target="_blank"
                    >
                    {{ data.item.disease.name }}
                    </router-link>
                </template>

                <template v-slot:cell(created_on)="data">{{ simpleDateTime(data.value).date }}</template>

                <template v-slot:cell(status)="data">
                  <span class="pub-status">
                    <icon :class="setClass(data.value)" :name="setIcon(data.value)" v-b-tooltip.hover :title="data.value"/>
                    {{ titleCase(data.value) }}
                  </span>
                </template>

                <template v-slot:cell(references)="data">
                    <VariomesLitPopover v-if="isDashboard" :pubmeta="{ pmid: data.value }"
                        :variant="data.item.variant.name"
                        :gene="data.item.variant.gene.symbol"
                        :disease="data.item.disease.name"
                    />
                    <VariomesLitPopover v-else :pubmeta="{ pmid: data.value }" v-bind="variomesParams" />
                </template>

                <template v-slot:cell(created_on)="data">
                    <DateTimeField :datetime="data.value" />
                </template>

                <template v-slot:cell(last_modified)="data">
                    <DateTimeField :datetime="data.value" />
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
                            <icon name="pen-alt" />Edit
                        </b-button>
                        <b-button v-else
                            target="_blank"
                            class="centered-icons"
                            size="sm"
                            :href="editEntryURL(data.item)"
                            style="min-width: 75px;"
                        >
                            <icon name="eye" />View
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
                </template>

                <template v-slot:extra_commands>
                    <div v-if="isSubmittable" style="margin-bottom: 10px; margin-right: 10px;">
                        <b-button :disabled="selectedCount <= 0" variant="info" @click="submitSelected" style="height: 34px;">
                        Submit {{ selectedCount }} {{ selectedCount === 1 ? 'Entry' : 'Entries' }}
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
                    <div v-else>Error: no curation entry selected</div>
                </div>
            </b-modal>
        </b-card-body>
    </b-card>
</template>

<script>
// import fields from "@/data/curation/evidence/fields.json";
import { HTTP } from "@/router/http";
import PagedTable from "@/components/widgets/PagedTable";
import VariomesLitPopover from "@/components/widgets/VariomesLitPopover";
import BroadcastChannel from "broadcast-channel";
import {simpleDateTime, titleCase} from "@/utils";
import EvidenceHistory from "@/components/curation/widgets/EvidenceHistory";
import { mapGetters } from "vuex";
import moment from 'moment';

const DateTimeField = {
    props: {
        datetime: { required: true }
    },
    render(h) {
        const fullDate = moment(this.datetime).format("h:mm a");
        const parsed = simpleDateTime(this.datetime);

        return (
            <span v-b-tooltip={fullDate}>{parsed.date}</span>
        );
    }
};


const full_fields = [
    {
        key: "status",
        label: "Status",
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
        formatter: (x, k, obj) => obj.disease.name
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
    components: { EvidenceHistory, VariomesLitPopover, PagedTable, DateTimeField },
    props: {
        variant: { type: Object, required: false },
        disease_id: { type: Number, required: false },
        isDashboard: { type: Boolean, required: false, default: false },
        isSubmittable: { type: Boolean, required: false, default: false },
        onlySubmitted: { type: Boolean, required: false, default: false },
        notSubmitted: { type: Boolean, required: false, default: false },
        hasHeader: { type: Boolean, default: false },
        headerTitle: { type: String, required: false, default: "Curation Entries" },
        cardHeaderBg: { type: String, required: false, default: "light" },
        cardTitleVariant: { type: String, required: false, default: "primary" }
    },
    data() {
        return {
            channel: new BroadcastChannel("curation-update"),
            filterCurator: false,
            history_entry_id: null,
            filter: null,
            selected: {}
        };
    },
    created() {
        this.channel.onmessage = (msg) => {
            if (this.$refs.paged_table) {
                this.$refs.paged_table.refresh();
            }
        };
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
                this.variant && `variants=${this.variant.id}`,
                this.disease_id && `disease=${this.disease_id}`,
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
        rowClass(item, type) {
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
            // FIXME: presumes again that the first variant is the 'main' one; do we want to assume that, or split it
            //  into a seprate field?
            // FIXME: alternatively, should curation entries have a 'main' variant at all, or should we restructure the
            //  URL to remove the gene, variant, disease refererences?

            const [gene_id, variant_id, disease_id] = [
                entry.variant.gene.id,
                entry.variant.id,
                entry.disease.id
            ];

            return `/curation/gene/${gene_id}/variant/${variant_id}/disease/${disease_id}/entry/${entry.id}`;
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
        submitSelected() {
            const prompt = (this.selectedCount === 1
                ? 'Are you sure you want to submit this entry?'
                : `Are you sure that you want to submit these ${this.selectedCount} entries?`) +
            '\n\nYou will no longer be able to edit your entries after submitting them!';

            if (confirm(prompt)) {
                const entryIDs = Object.keys(this.selected).join(",");

                // TODO: set the status of all the selected entries to 'submitted'
                HTTP.post(`/curation_entries/bulk_submit?items=${entryIDs}`)
                    .then(result => {
                        this.channel.postMessage(`Submitted IDs ${entryIDs}`);
                        this.$snotify.info(`${result.data.changed} ${result.data.changed == 1 ? 'entry' : 'entries'} submitted`);
                        this.$refs.paged_table.refresh();
                    })
                    .catch((err) => {
                        this.$snotify.error("Failed to submit entries");
                        console.warn(err);
                    });
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
</style>
