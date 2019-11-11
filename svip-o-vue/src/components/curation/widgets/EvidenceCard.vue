<template>
    <b-card class="shadow-sm mb-3" align="left" no-body>
        <b-card-body class="p-0">
            <PagedTable
                id="evidence_table"
                ref="paged_table"
                class="mb-0"
                thead-class="bg-primary text-light"
                primary-key="id"
                :tbody-tr-class="rowClass"
                :items="evidences"
                :fields="fields"
                sort-by="created_on"
                sort-desc
                show-empty
                empty-text="There seems to be an error"
                :apiUrl="`/curation_entries?variants=${variant.id}&disease=${disease_id}`"
                :postMapper="colorCurationRows"
            >
                <template v-slot:cell(status)="data">
                    <span class="pub-status">
                        <icon
                            :class="setClass(data.value)"
                            :name="setIcon(data.value)"
                            v-b-tooltip.hover
                            :title="data.value"
                        /> {{ titleCase(data.value) }}
                    </span>
                </template>

                <template v-slot:cell(references)="data">
                    <VariomesLitPopover
                        :pubmeta="{ pmid: data.value }" :variant="variant.name" :gene="variant.gene.symbol"
                        :disease="disease.name"
                    />
                </template>

                <template v-slot:cell(created_on)="data">
                    {{ new Date(data.value).toLocaleString() }}
                </template>

                <template v-slot:cell(action)="data">
                    <span class="action-tray">
                        <b-button target="_blank" class="centered-icons" size="sm" :href="editEntryURL(data.item.id)">
                            <icon class="mr-1" name="pen-alt" />
                            Edit
                        </b-button>
                        <b-button class="centered-icons btn-danger" size="sm" @click="deleteEntry(data.item.id)">
                            <icon class="mr-1" name="trash" /> Delete
                        </b-button>
                    </span>
                </template>
            </PagedTable>
        </b-card-body>
    </b-card>
</template>

<script>
// import fields from "@/data/curation/evidence/fields.json";
import {HTTP} from '@/router/http';
import PagedTable from "@/components/widgets/PagedTable";
import VariomesLitPopover from "@/components/widgets/VariomesLitPopover";
import BroadcastChannel from 'broadcast-channel';
import {titleCase} from "@/utils";

const fields = [
    {
        "key": "status",
        "label": "Status",
        "sortable": true
    },
    {
        "key": "references",
        "label": "Reference",
        "sortable": true
    },
    {
        "key": "type_of_evidence",
        "label": "Type of evidence",
        "sortable": true
    },
    {
        "key": "drug",
        "label": "Drug",
        "sortable": true
    },
    {
        "key": "effect",
        "label": "Effect",
        "sortable": true
    },
    {
        "key": "tier_level_criteria",
        "label": "Tier criteria",
        "sortable": false
    },
    {
        "key": "tier_level",
        "label": "Tier criteria",
        "sortable": true
    },
    {
        "key": "owner_name",
        "label": "Curator",
        "sortable": true
    },
    {
        "key": "created_on",
        "label": "Created on",
        "sortable": true
    },
    {
        key: "action",
        label: "",
        sortable: false
    }
];

export default {
    name: "EvidenceCard",
    components: {VariomesLitPopover, PagedTable},
    props: {
        variant: { type: Object, required: true },
        disease_id: { type: Number, required: true }
    },
    data() {
        return {
            fields,
            channel: new BroadcastChannel('curation-update'),
            evidences: []
        };
    },
    created() {
        this.channel.onmessage = (msg) => {
            this.$refs.paged_table.refresh();
        };
    },
    computed: {
        disease() {
            return this.variant.svip_data.diseases.find(
                element => element.disease_id === this.disease_id
            );
        },
    },
    methods: {
        titleCase,
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
            } else if (status === "review") {
                return "tasks";
            } else {
                return "pen-alt";
            }
        },
        editEntryURL(entry_id) {
            return `/curation/gene/${this.variant.gene.id}/variant/${this.variant.id}/disease/${this.disease_id}/entry/${entry_id}`;
        },
        deleteEntry(entry_id) {
            if (confirm('Are you sure that you want to delete this entry?')) {
                HTTP.delete(`/curation_entries/${entry_id}`)
                    .then(() => {
                        this.$snotify.info("Entry deleted!");
                        this.$refs.paged_table.refresh();
                    })
                    .catch(() => {
                        this.$snotify.error("Failed to delete entry");
                    })
            }
        },
        colorCurationRows(data) {
            // maps each row to a color variant based on its status (e.g., drafts are gray)
            return data.map(x => {
                if (x.status === 'draft') {
                    x._rowVariant = 'light';
                }
                return x;
            })
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
    flex-wrap: wrap;
    justify-content: flex-end;
}
.action-tray .btn {
    min-width: 100px;
    margin-left: 5px;
    margin-bottom: 5px;
}

#evidence_table >>> .table {
    margin-bottom: 0;
}
</style>
