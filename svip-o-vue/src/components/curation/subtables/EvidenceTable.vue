<template>
  <b-table :fields="fields" :items="items" :show-empty="true" :small="true">
    <template slot="display" slot-scope="row">
      <b-link @click="row.toggleDetails">
        <icon :name="row.detailsShowing ? 'chevron-up' : 'chevron-down'"></icon>
      </b-link>
    </template>
    <template slot="references" slot-scope="data">
      <VariomesLitPopover
        :pubmeta="{ pmid: trimPrefix(data.value, 'PMID:') }"
        :variant="variant.name"
        :gene="variant.gene.symbol"
        :disease="data.item.name"
      />
    </template>

    <template slot="row-details" slot-scope="row">
      <b-card no-body class="border-0">
        <b-container fluid>
          <b-row class="p-3 bg-light">
            <b-col>
              <b>Complementary information</b>
              <br />
              {{ row.item.summary }}
              <br />
              <br />
              <b>Personal comment (Only for curators)</b>
              <br />
              {{ row.item.comment == null ? '-' : row.item.comment }}
            </b-col>
          </b-row>
        </b-container>
      </b-card>
    </template>

    <template slot="empty">
      <div class="empty-table-msg">- no evidence items -</div>
    </template>
  </b-table>
</template>

<script>
import { trimPrefix } from "@/utils";
import VariomesLitPopover from "@/components/widgets/VariomesLitPopover";

export default {
  name: "EvidenceTable",
  components: { VariomesLitPopover },
  props: {
    variant: { type: Object, required: true },
    items: {
      type: Array,
      required: true
    }
  },
  data() {
    return {
      fields: [
        { key: "display", label: "", sortable: false },
        { key: "type_of_evidence", label: "Evidence Type", sortable: true },
        { key: "drug", label: "Drug", sortable: true },
        { key: "effect", label: "Effect", sortable: true },
        {
          key: "tier_level_criteria",
          label: "Tier Criteria",
          sortable: true
        },
        {
          key: "mutation_origin",
          label: "Mutation Origin",
          sortable: true
        },
        { key: "support", label: "Support", sortable: true },
        { key: "references", label: "References", sortable: false },
        {
          key: "curator",
          label: "Curator",
          sortable: false
        },
        {
          key: "date",
          label: "Date",
          sortable: true
        }
      ]
    };
  },
  methods: {
    trimPrefix
  }
};
</script>

<style>
</style>
