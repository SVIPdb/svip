<template>
  <!-- <div class="col-sm-auto"> -->
  <div class="card mt-3">
    <div class="card-header">
      <div class="card-title">Samples details</div>
    </div>
    <!-- <div class="card-body"> -->
      <b-table :fields="fields" :items="samplesDataFiltered">
        <template slot="actions">
          <!-- We use @click.stop here to prevent a 'row-clicked' event from also happening -->
          <!-- <b-button size="sm" @click.stop="row.toggleDetails">
          {{ row.detailsShowing ? "Hide" : "Show" }} Details
        </b-button> -->
        </template>
      <!-- <template slot="name" slot-scope="row">
      {{ row.item.name }}
    </template> -->
    </b-table>
    <!-- </div> -->
  </div>
<!-- </div> -->
</template>

<script>
// import {normalizeItemList, titleCase, desnakify} from "@/utils";
// import {makeAssociationProvider} from "../../item_providers/association_provider";
// import PubmedPopover from "@/components/widgets/PubmedPopover";
// import RowDetailsHeader from "@/components/genes/sources/shared/RowDetailsHeader";

import { mapGetters } from "vuex"

export default {
	name: "svipShowSamples",
	props: {
		disease_type: String
	},
	// components: {RowDetailsHeader, PubmedPopover},
	data() {
		return {
			fields: [
        {
			    key: "disease",
			    label: "Disease",
			    sortable: true
			  },
        {
			    key: "sample_id",
			    label: "Sample ID",
			    sortable: true
			  },
        {
			    key: "year_of_birth",
			    label: "Year Of Birth",
			    sortable: true
			  },
        {
			    key: "gender",
			    label: "Gender",
			    sortable: true
			  },
        {
			    key: "hospital",
			    label: "Hospital",
			    sortable: true
			  },
        {
			    key: "medical_service",
			    label: "Medical Service",
			    sortable: true
			  },
        {
			    key: "provider_annotation",
			    label: "Provider Annotation",
			    sortable: true
			  },
        {
			    key: "sample_tissue",
			    label: "Sample Tissue",
			    sortable: true
			  },
        {
			    key: "tumor_purity",
			    label: "Tumor Purity",
			    sortable: true
			  },
        {
			    key: "tnm_stage",
			    label: "TNM Stage",
			    sortable: true
			  },
        {
			    key: "sample_type",
			    label: "Sample Type",
			    sortable: true
			  },
        {
			    key: "sample_site",
			    label: "Sample Site",
			    sortable: true
			  },
        {
			    key: "specimen_type",
			    label: "Specimen Type",
			    sortable: true
			  },
        {
			    key: "sequencing_date",
			    label: "Sequencing Date",
			    sortable: true
			  },
        {
			    key: "panel",
			    label: "Panel",
			    sortable: true
			  },
        {
			    key: "coverage",
			    label: "Coverage",
			    sortable: true
			  },
        {
			    key: "calling_strategy",
			    label: "Calling Strategy",
			    sortable: true
			  },
        {
			    key: "caller",
			    label: "Caller",
			    sortable: true
			  },
        {
			    key: "aligner",
			    label: "Aligner",
			    sortable: true
			  },
			  {
			    key: "software",
			    label: "Software",
			    sortable: true
			  },
			  {
			    key: "software_version",
			    label: "Software Version",
			    sortable: true
			  },
        {
			    key: "platform",
			    label: "Platform",
			    sortable: true
			  },
        {
			    key: "contact",
			    label: "Contact",
			    sortable: true
			  }
			]
		}
	},
	computed: {
		...mapGetters({
			variant: 'variant'
		}),
		samplesDataFiltered () {
			let vm = this;
      //// for now the disease don't match so don't filter
			// return  _.filter(this.variant.svip_data.samples, x => {
			// 	return x.disease === vm.disease_type;
			// })
      return this.variant.svip_data.samples;
		}
	},
	methods: {
	}
}
</script>

<style scoped>
.card-header:first-child {
    background-color: rgb(128, 0, 128, 0.5);
}
</style>
