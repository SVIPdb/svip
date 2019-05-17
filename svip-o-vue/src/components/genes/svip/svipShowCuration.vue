<template>
	<!-- <div class="col-sm-auto"> -->
	<div class="card mt-3">
		<div class="card-header">
			<div class="card-title">Curation details</div>
		</div>
		<!-- <div class="card-body"> -->
		<b-table :fields="fields" :items="curationDataFiltered">
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
	name: "svipShowCuration",
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
					key: "type_of_evidence",
					label: "Type Of Evidence",
					sortable: true
				},
				{
					key: "drug",
					label: "Drug",
					sortable: true
				},
				{
					key: "effect",
					label: "Effect",
					sortable: true
				},
				{
					key: "tier_level_criteria",
					label: "Tier Level Criteria",
					sortable: true
				},
				{
					key: "summary",
					label: "Summary",
					sortable: true
				},
				{
					key: "support",
					label: "Support",
					sortable: true
				},
				{
					key: "references",
					label: "References",
					sortable: true
				}
			]
		}
	},
	computed: {
		...mapGetters({
			variant: 'variant'
		}),
		curationDataFiltered () {
			let vm = this;
			return  _.filter(this.variant.svip_data.curation_entries, x => {
				return x.disease === vm.disease_type;
			})
		}
	},
	methods: {
	}
}
</script>

<style scoped>
.card-header:first-child {
    background-color: rgba(0, 128, 0, 0.5);
}
</style>
