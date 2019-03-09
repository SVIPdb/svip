<template>
	<div class="row">
		<div class="col-4">
			<b-card>
				<h6 class="card-subtitle mb-2 text-muted">
					Diseases
					<i class="float-right" v-if="!filters.disease">click on a disease to filter the table</i>
					<span class="float-right badge badge-primary filter-disease" v-else>
						{{ filters.disease }}
						<button type="button" class="close small ml-3" aria-label="Close" style="font-size: 14px" @click="filters.disease = ''">
								<span aria-hidden="true">&times;</span>
						</button>
					</span>
				</h6>

				<table class="table table-sm table-hover">
					<thead>
						<tr>
							<th>Disease</th>
							<th># of Occcurences</th>
						</tr>
					</thead>
					<tbody>
						<tr v-for="(nb, d) in row.item.diseases" :key="d" @click="filters.disease = d" :class="filters.disease === d ? 'pointer table-active' : 'pointer'">
							<td>{{ d }}</td>
							<td>{{ nb }}</td>
						</tr>
					</tbody>
				</table>
			</b-card>

			<b-card style="margin-top: 1em;">
				<h6 class="card-subtitle mb-2 text-muted">
					Tissue Types
					<i class="float-right" v-if="!filters.tissue">click on a tissue type to filter the table</i>
					<span class="float-right badge badge-primary filter-tissue" v-else>
						{{ filters.tissue }}
						<button type="button" class="close small ml-3" aria-label="Close" style="font-size: 14px" @click="filters.tissue = ''">
								<span aria-hidden="true">&times;</span>
						</button>
					</span>
				</h6>
				<table class="table table-sm table-hover">
					<thead>
						<tr>
							<th>Tissue Type</th>
							<th># of Samples</th>
						</tr>
					</thead>
					<tbody>
						<tr v-for="(nb, d) in tissue_types" :key="d" @click="filters.tissue = d" :class="filters.tissue === d ? 'pointer table-active' : 'pointer'">
							<td>{{ deslugify(d) }}</td>
							<td>{{ nb }}</td>
						</tr>
					</tbody>
				</table>
			</b-card>
		</div>

		<div class="col-8">
			<b-card>
				<h6 class="card-subtitle mb-2 text-muted">
					Samples: {{ clinical_filtered.length }}
					<span :class="`float-right badge badge-primary filter-${k}`" :key="k" v-for="[k,v] in Object.entries(filters).filter(x => x[1])">
					{{ v }}
						<button type="button" class="close small ml-3" aria-label="Close" style="font-size: 14px" @click="filters[k] = ''">
								<span aria-hidden="true">&times;</span>
						</button>
					</span>
				</h6>

				<table class="table table-sm">
					<tr>
						<th>Disease</th>
						<th>Tissue</th>
						<th>References</th>
					</tr>
					<tr v-for="(c, idx) in clinical_filtered" :key="idx">
						<td>
							<a v-if="c.evidence_url" :href="c.evidence_url" target="_blank">{{ c.disease }}</a>
							<span v-else>{{ c.disease }}</span>
						</td>
						<td>{{ deslugify(c.context.description) }}</td>
						<td>
							<template v-for="(p, i) in c.publications">
								<a :href="p.url" target="_blank" :key="`${i}_link`">{{ p.pmid }}</a><span :key="`${i}_comma`" v-if=" i < c.publications .length - 1">, </span>
							</template>
						</td>
					</tr>
				</table>
			</b-card>
		</div>
	</div>
</template>

<script>
import _ from 'lodash';
import {normalizeItemList, titleCase} from "@/utils";

export default {
	name: "CosmicRowDetails",
	data: function() {
		return {
			filters: {
				disease: null,
				tissue: null
			}
		};
	},
	props: {
		row: {type: Object, required: true}
	},
	computed: {
		clinical_items() {
			return this.row.item.clinical.map(x => ({...x, tissue: this.deslugify(x.context.description)}));
		},
		tissue_types() {
			const counts = _.countBy(this.clinical_items, x => x.tissue);
			return _.fromPairs(_.sortBy(_.toPairs(counts), 1).reverse());
		},
		clinical_filtered() {
			return this.filterBy(this.clinical_items, this.filters);
		}
	},
	methods: {
		filterBy(items, criteria) {
			const items_mapped = items.map(x => ({...x, tissue: this.deslugify(x.context.description)}));
			return items_mapped.filter(x => Object.entries(criteria).every(([k, v]) => !v || x[k] === v));
		},
		normalizeItemList, titleCase,
		deslugify(x) {
			return titleCase(x.split("_").join(" "));
		}
	}
}
</script>

<style scoped>
.badge {
	font-size: 13px;
	margin-left: 5px;
}
.filter-disease {
	background-color: #598059;
}
.filter-tissue {
	background-color: #596680;
}
</style>
