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
          <b-button
            class="ml-3"
            size="sm"
            variant="primary"
            @click="filterCurator = true"
          >My curations</b-button>
          <b-button
            class="ml-3"
            size="sm"
            variant="primary"
            @click="filterCurator = false"
          >All curations</b-button>
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
        :items="evidences"
        :fields="fields"
        sort-by="created_on"
        sort-desc
        show-empty
        empty-text="There seems to be an error"
        :external-search="filter"
        :apiUrl="apiUrl"
        :postMapper="colorCurationRows"
      >
        <template v-slot:cell(display)="row">
          <expander :row="row" />
        </template>

        <template v-slot:cell(status)="data">
          <span class="pub-status">
            <icon
              :class="setClass(data.value)"
              :name="setIcon(data.value)"
              v-b-tooltip.hover
              :title="data.value"
            />
            {{ titleCase(data.value) }}
          </span>
        </template>

        <template v-slot:cell(references)="data">
          <VariomesLitPopover :pubmeta="{ pmid: data.value }" v-bind="variomesParams" />
        </template>

        <template v-slot:cell(created_on)="data">{{ new Date(data.value).toLocaleString() }}</template>

        <template v-slot:cell(last_modified)="data">{{ new Date(data.value).toLocaleString() }}</template>

        <template v-slot:cell(action)="data">
          <span class="action-tray">
            <b-button
              target="_blank"
              class="centered-icons"
              size="sm"
              :href="editEntryURL(data.item)"
            >
              <icon name="pen-alt" />Edit
            </b-button>
            <b-button
              class="btn-danger"
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
import { titleCase } from "@/utils";
import EvidenceHistory from "@/components/curation/widgets/EvidenceHistory";
import { mapGetters } from "vuex";

const fields = [
    {
        key: "display",
        sortable: false,
        thClass: "d-none",
        tdClass: "d-none"
    },
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

export default {
    name: "EvidenceCard",
    components: { EvidenceHistory, VariomesLitPopover, PagedTable },
    props: {
        variant: { type: Object, required: false },
        disease_id: { type: Number, required: false },
        hasHeader: { type: Boolean, default: false },
        headerTitle: { type: String, required: false, default: "Curation Entries" },
        cardHeaderBg: { type: String, required: false, default: "light" },
        cardTitleVariant: { type: String, required: false, default: "primary" }
    },
    data() {
        return {
            fields,
            channel: new BroadcastChannel("curation-update"),
            filterCurator: false,
            evidences: [],
            history_entry_id: null,
            filter: null
        };
    },
    created() {
        this.channel.onmessage = msg => {
            this.$refs.paged_table.refresh();
        };
    },
    computed: {
        ...mapGetters(["userID"]),
        disease() {
            if (!this.variant || !this.disease_id) {
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
                this.filterCurator && `owner=${this.userID}`
            ].filter(x => x);

            return `/curation_entries${params ? "?" + params.join("&") : ""}`;
        },
        variomesParams() {
            return {
                variant: this.variant && this.variant.name,
                gene: this.variant && this.variant.gene.symbol,
                disease: this.disease && this.disease.name
            };
        }
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
        editEntryURL(entry) {
            // FIXME: presumes again that the first variant is the 'main' one; do we want to assume that, or split it
            //  into a seprate field?
            // FIXME: alternatively, should curation entries have a 'main' variant at all, or should we restructure the
            //  URL to remove the gene, variant, disease refererences?

            const [gene_id, variant_id, disease_id] = [
                entry.formatted_variants[0].g_id,
                entry.formatted_variants[0].id,
                entry.disease
            ];

            return `/curation/gene/${gene_id}/variant/${variant_id}/disease/${disease_id}/entry/${entry.id}`;
        },
        deleteEntry(entry_id) {
            if (confirm("Are you sure that you want to delete this entry?")) {
                HTTP.delete(`/curation_entries/${entry_id}`)
                    .then(() => {
                        this.$snotify.info("Entry deleted!");
                        this.$refs.paged_table.refresh();
                    })
                    .catch(() => {
                        this.$snotify.error("Failed to delete entry");
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
