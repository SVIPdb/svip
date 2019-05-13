<template>
	<div class="row">
		<div class="col-3 col-sm-4">
			<!--
      -----------------------------------------------------------------------------------------------------
      ---
      -----------------------------------------------------------------------------------------------------
      -->
			<b-card>
				<table class="table table-sm table-hover filtering-table">
					<thead>
						<tr>
							<th>{{curationData}} TOTO</th>
							<th># of Samples</th>
              <!-- {{$route}} -->
						</tr>
					</thead>
					<tbody>
						<!-- <tr v-for="d in row.item.diseases" :key="d.disease" @click="currentFilter.phenotype__term = d.disease" :class="currentFilter.phenotype__term === d.disease ? 'pointer table-active' : 'pointer'">
							<td>{{ titleCase(d.disease) }}</td>
							<td>{{ d.count.toLocaleString() }}</td>
						</tr> -->
					</tbody>
				</table>
			</b-card>
		</div>
	</div>
</template>

<script>
// import {normalizeItemList, titleCase, desnakify} from "@/utils";
// import {makeAssociationProvider} from "../../item_providers/association_provider";
// import PubmedPopover from "@/components/widgets/PubmedPopover";
// import RowDetailsHeader from "@/components/genes/sources/shared/RowDetailsHeader";

export default {
	name: "svipShowCuration",
	props: {
		// row: {type: Object, required: true}
    curationData: Object
	},
	// components: {RowDetailsHeader, PubmedPopover},
	data() {
		return {
			// currentFilter: {
			// 	phenotype__term: '',
			// 	environmentalcontext__description: '',
			// 	search: ''
			// },
			// currentPage: 1,
			// perPage: 20,
			// totalRows: this.row.item.association_count,
			// fields: [
			// 	{
			// 		key: "disease",
			// 		label: "Disease",
			// 		sortable: true
			// 	},
			// 	{
			// 		key: "contexts",
			// 		label: "Tissue",
			// 		sortable: true
			// 	},
			// 	{
			// 		key: "publications",
			// 		label: "References",
			// 		sortable: false
			// 	},
			// ]
		}
	},
	computed: {
		// packedFilter() {
		// 	return JSON.stringify(this.currentFilter);
		// }
	},
	methods: {
		// metaUpdated({ count }) {
		// 	this.totalRows = count;
		// },
		// makeAssociationProvider,
		// normalizeItemList,
		// titleCase,
		// desnakify
	}
}
</script>

<style scoped>
</style>
