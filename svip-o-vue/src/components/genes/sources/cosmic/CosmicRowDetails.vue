<template>
	<div class="row">
		<div class="col-3 col-sm-4">
			<!--
      -----------------------------------------------------------------------------------------------------
      --- disease filter
      -----------------------------------------------------------------------------------------------------
      -->
			<b-card>
				<h6 class="card-subtitle mb-2 text-muted">
					Diseases
					<i class="float-right" v-if="!currentFilter.phenotype__term">click on a disease to filter the table</i>
					<span class="float-right badge badge-primary filter-phenotype__term" v-else>
						{{ currentFilter.phenotype__term }}
						<button type="button" class="close small ml-3" aria-label="Close" style="font-size: 14px" @click="currentFilter.phenotype__term = ''">
								<span aria-hidden="true">&times;</span>
						</button>
					</span>
				</h6>

				<table class="table table-sm table-hover filtering-table">
					<thead>
						<tr>
							<th>Disease</th>
							<th># of Samples</th>
						</tr>
					</thead>
					<tbody>
						<tr v-for="d in row.item.diseases" :key="d.disease" @click="currentFilter.phenotype__term = d.disease" :class="currentFilter.phenotype__term === d.disease ? 'pointer table-active' : 'pointer'">
							<td>{{ titleCase(d.disease) }}</td>
							<td>{{ d.count.toLocaleString() }}</td>
						</tr>
					</tbody>
				</table>
			</b-card>

			<!--
			-----------------------------------------------------------------------------------------------------
			--- tissue filter
			-----------------------------------------------------------------------------------------------------
			-->
			<b-card style="margin-top: 1em;">
				<h6 class="card-subtitle mb-2 text-muted">
					Tissue Types
					<i class="float-right" v-if="!currentFilter.environmentalcontext__description">click on a tissue type to filter the table</i>
					<span class="float-right badge badge-primary filter-environmentalcontext__description" v-else>
						{{ currentFilter.environmentalcontext__description }}
						<button type="button" class="close small ml-3" aria-label="Close" style="font-size: 14px" @click="currentFilter.environmentalcontext__description = ''">
								<span aria-hidden="true">&times;</span>
						</button>
					</span>
				</h6>
				<table class="table table-sm table-hover filtering-table">
					<thead>
						<tr>
							<th>Tissue Type</th>
							<th># of Samples</th>
						</tr>
					</thead>
					<tbody>
						<tr v-for="d in row.item.contexts" :key="d.context" @click="currentFilter.environmentalcontext__description = d.context" :class="currentFilter.environmentalcontext__description === d.context ? 'pointer table-active' : 'pointer'">
							<td>{{ desnakify(d.context) }}</td>
							<td>{{ d.count.toLocaleString() }}</td>
						</tr>
					</tbody>
				</table>
			</b-card>
		</div>

		<!--
		=====================================================================================================
		=== samples table
		=====================================================================================================
		-->
		<div class="col-9 col-sm-8">
			<b-card>
				<h6 class="card-subtitle mb-2 text-muted">
					Samples: {{ totalRows.toLocaleString() }}
					<span :class="`float-right badge badge-primary filter-${k}`" :key="k" v-for="[k,v] in Object.entries(currentFilter).filter(x => x[1])">
					{{ v }}
						<button type="button" class="close small ml-3" aria-label="Close" style="font-size: 14px" @click="currentFilter[k] = ''">
								<span aria-hidden="true">&times;</span>
						</button>
					</span>
				</h6>

				<b-table
					:fields="fields" class="table-sm" :api-url="row.item.associations_url" :items="makeAssociationProvider(this.metaUpdated)"
					:per-page="perPage" :current-page="currentPage" :filter="packedFilter"
				>
					<template slot="disease" slot-scope="c">
						<a v-if="c.item.evidence_url" :href="c.item.evidence_url" target="_blank">{{ c.value }}</a>
						<span v-else>{{ c.value }}</span>
					</template>
					<template slot="contexts" slot-scope="c">{{ desnakify(c.value) }}</template>
					<template slot="publications" slot-scope="c">
						<template v-for="(p, i) in c.value">
							<a :href="p.url" target="_blank" :key="`${i}_link`">{{ p.pmid }}</a><span :key="`${i}_comma`" v-if=" i < c.item.publications .length - 1">, </span>
						</template>
					</template>
				</b-table>

				<b-pagination v-if="totalRows > perPage" v-model="currentPage" :total-rows="totalRows" :per-page="perPage" />
			</b-card>
		</div>
	</div>
</template>

<script>
import {normalizeItemList, titleCase, desnakify} from "@/utils";
import {makeAssociationProvider} from "../../item_providers/association_provider";
import PubmedPopover from "@/components/widgets/PubmedPopover";

export default {
	name: "CosmicRowDetails",
	props: {
		row: {type: Object, required: true}
	},
	components: {PubmedPopover},
	data() {
		return {
			currentFilter: {
				phenotype__term: '',
				environmentalcontext__description: ''
			},
			currentPage: 1,
			perPage: 100,
			totalRows: this.row.item.association_count,
			fields: [
				{
					key: "disease",
					label: "Disease",
					sortable: false
				},
				{
					key: "contexts",
					label: "Tissue",
					sortable: false
				},
				{
					key: "publications",
					label: "References",
					sortable: false
				},
			]
		}
	},
	computed: {
		packedFilter() {
			return JSON.stringify(this.currentFilter);
		}
	},
	methods: {
		metaUpdated({ count }) {
			this.totalRows = count;
		},
		makeAssociationProvider,
		normalizeItemList,
		titleCase,
		desnakify
	}
}
</script>

<style scoped>
.badge {
	font-size: 13px;
	margin-left: 5px;
}
.filter-phenotype__term {
	background-color: #598059;
}
.filter-environmentalcontext__description {
	background-color: #596680;
}
</style>
