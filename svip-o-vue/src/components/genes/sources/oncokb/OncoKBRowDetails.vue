<template>
	<div class="row">
		<div class="col-xl-3 col-4">
			<b-card>
				<h6 class="card-subtitle mb-2 text-muted">
					Diseases
					<i class="float-right" v-if="!currentFilter.phenotype__term">click on a disease to filter the drugs table</i>
					<span class="float-right badge badge-primary" v-if="currentFilter.phenotype__term" style="font-size: 13px">
						{{ titleCase(currentFilter.phenotype__term) }}
						<button type="button" class="close small ml-3" aria-label="Close" style="font-size: 14px" @click="currentFilter.phenotype__term = ''">
								<span aria-hidden="true">&times;</span>
						</button>
					</span>
				</h6>
				<table class="table table-sm table-hover filtering-table">
					<thead>
						<tr>
							<th>Disease</th>
							<th># of Occcurences</th>
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
		</div>

		<!-- FIXME: add filtering on categorical columns w/a dropdown -->

		<div class="col-xl-9 col-8">
			<b-card>
				<h6 class="card-subtitle mb-2 text-muted">
					Evidences: {{ totalRows.toLocaleString() }}
					<span class="float-right badge badge-primary" v-if="currentFilter.phenotype__term" style="font-size: 13px">
						{{ titleCase(currentFilter.phenotype__term) }}
						<button type="button" class="close small ml-3" aria-label="Close" style="font-size: 14px" @click="currentFilter.phenotype__term = ''">
								<span aria-hidden="true">&times;</span>
						</button>
					</span>
				</h6>

				<b-table
					:fields="fields" class="table-sm filter-table" :api-url="row.item.associations_url" :items="makeAssociationProvider(this.metaUpdated)"
					:per-page="perPage" :current-page="currentPage" :filter="packedFilter"
				>
					<template slot="disease" slot-scope="c">
						<a v-if="c.item.evidence_url" :href="c.item.evidence_url" target="_blank">{{ c.value }}</a>
						<span v-else>{{ c.value }}</span>
					</template>
					<template slot="drug" slot-scope="c">{{ normalizeItemList(c.value) }}</template>
					<template slot="publications" slot-scope="c">
						<template v-for="(p, i) in c.value">
							<PubmedPopover :pubmeta="p" :key="`${i}_link`" /><span :key="`${i}_comma`" v-if=" i < c.item.publications .length - 1">, </span>
						</template>
					</template>
				</b-table>

				<b-pagination v-if="totalRows > perPage" v-model="currentPage" :total-rows="totalRows" :per-page="perPage" />
			</b-card>
		</div>
	</div>
</template>

<script>
import {normalizeItemList, titleCase} from "@/utils";
import {makeAssociationProvider} from '@/components/genes/item_providers/association_provider';
import store from "@/store";
import PubmedPopover from "@/components/widgets/PubmedPopover";

export default {
	name: "OncoKBRowDetails",
	components: {PubmedPopover},
	props: {
		row: {type: Object, required: true}
	},
	data() {
		return {
			currentFilter: {
				phenotype__term: ''
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
					key: "evidence_type",
					label: "Evidence Type",
					sortable: true
				},
				{
					key: "clinical_significance",
					label: "Clinical Significance",
					sortable: true
				},
				{
					key: "evidence_level",
					label: "Tier",
					sortable: true
				},
				{
					key: "drug_labels",
					label: "Drug",
					sortable: true
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
		titleCase
	}
}
</script>

<style scoped>

</style>
