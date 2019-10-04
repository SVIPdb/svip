<template>
  <b-card-text>
    <b-table
      v-if="(groups && groups.includes('clinicians'))"
      :fields="fields"
      :items="sample_provider"
      :small="true"
      :show-empty="true"
      class="table-sm filter-table"
      :api-url="row.item.samples_url"
      :per-page="perPage"
      :current-page="currentPage"
      :filter="packedFilter(currentFilter)"
    >
      <template v-slot:cell(contact)="entry">
        <b-button
          :href="`${entry.value}?subject=Regarding Sample ID ${entry.item.sample_id}`"
          size="sm"
          variant="info"
        >Contact</b-button>
      </template>

      <template v-slot:cell(sample_tissue)="entry">
        <a
          href="javascript:void(0);"
          @click.stop="() => changeSubpanel(entry, 'tumor')"
        >{{ entry.value }}</a>
      </template>

      <template v-slot:cell(panel)="entry">
        <a
          href="javascript:void(0);"
          @click.stop="() => changeSubpanel(entry, 'sequencing')"
        >{{ entry.value }}</a>
      </template>

      <template v-slot:empty="scope">
        <div class="empty-table-msg">- no samples -</div>
      </template>

      <template v-slot:row-details="entry">
        <div v-if="entry.item.curSubtable === 'tumor'" class="sample-subtable tumor-subtable">
          <table>
            <tr>
              <th v-for="field in tumor_fields" :key="field.key">{{ field.label }}</th>
            </tr>
            <tr>
              <td v-for="field in tumor_fields" :key="field.key">{{ entry.item[field.key] || '-' }}</td>
            </tr>
          </table>
        </div>
        <div
          v-else-if="entry.item.curSubtable === 'sequencing'"
          class="sample-subtable sequencing-subtable"
        >
          <table>
            <tr>
              <th v-for="field in sequencing_fields" :key="field.key">{{ field.label }}</th>
            </tr>
            <tr>
              <td
                v-for="field in sequencing_fields"
                :key="field.key"
              >{{ entry.item[field.key] || '-' }}</td>
            </tr>
          </table>
        </div>
      </template>
    </b-table>

    <div class="paginator-holster">
      <b-pagination
        v-if="totalRows > perPage"
        v-model="currentPage"
        :total-rows="totalRows"
        :per-page="perPage"
      />
    </div>
  </b-card-text>
</template>

<script>
import { makeSampleProvider } from "@/components/genes/variants/item_providers/sample_provider";

export default {
  name: "SampleTable",
  props: {
    variant: { required: true, type: Object },
    row: { required: true, type: Object },
    groups: { required: true, type: Array }
  },
  data() {
    return {
      name: this.row.item.name,
      totalRows: this.row.item.nb_patients,
      sortBy: "disease_name",
      currentFilter: {},
      currentPage: 1,
      perPage: 10,

      fields: [
        { key: "disease_name", label: "Disease", sortable: true },
        { key: "sample_id", label: "Sample ID", sortable: true },
        { key: "year_of_birth", label: "Year of birth", sortable: true },
        { key: "gender", label: "Gender", sortable: true },
        { key: "hospital", label: "Institution", sortable: true },
        { key: "medical_service", label: "Department", sortable: true },
        { key: "contact", label: "Contact", sortable: true },
        {
          key: "provider_annotation",
          label: "Provider Annotation",
          sortable: true
        },

        {
          key: "sample_tissue",
          label: "Tumor Sample",
          sortable: true
        } /* links to tumor details */,
        {
          key: "panel",
          label: "Sequencing Panel",
          sortable: true
        } /* links to sequencing details */
      ],

      tumor_fields: [
        { key: "tumor_purity", label: "Tumor Purity", sortable: true },
        { key: "tnm_stage", label: "TNM Stage", sortable: true },
        { key: "sample_type", label: "Sample Type", sortable: true },
        { key: "sample_site", label: "Sample Site", sortable: true },
        { key: "specimen_type", label: "Specimen Type", sortable: true },
        { key: "allele_frequency", label: "Tumor AF", sortable: true }
      ],

      sequencing_fields: [
        { key: "sequencing_date", label: "Sequencing Date", sortable: true },
        { key: "platform", label: "Platform", sortable: true },
        { key: "panel", label: "Sequencing Panel", sortable: true },
        { key: "coverage", label: "Coverage", sortable: true },
        { key: "calling_strategy", label: "Calling Strategy", sortable: true },
        { key: "caller", label: "Caller", sortable: true },
        { key: "aligner", label: "Aligner", sortable: true },
        { key: "software", label: "Software", sortable: true },
        { key: "software_version", label: "Software Version", sortable: true }
      ]
    };
  },
  methods: {
    packedFilter(filters) {
      return JSON.stringify(filters);
    },
    metaUpdated(response) {
      this.totalRows = response.count;
    },
    changeSubpanel(entry, subpanel_id) {
      entry.item._showDetails =
        entry.item.curSubtable === subpanel_id
          ? !entry.item._showDetails
          : true;
      entry.item.curSubtable = subpanel_id;
    }
  },
  computed: {
    sample_provider() {
      return makeSampleProvider(this.metaUpdated, {
        _showDetails: false,
        curSubtable: null
      });
    }
  }
};
</script>

<style scoped>
.paginator-holster {
  padding-left: 15px;
}
</style>
