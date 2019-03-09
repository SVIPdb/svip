<template>
	<div class="row">
		<div class="col-4">
			<b-card>
				<h6 class="card-subtitle mb-2 text-muted">
					Diseases
					<i class="float-right" v-if="!row.item.filter">click on a disease to filter the drugs table</i>
					<span class="float-right badge badge-primary" v-if="row.item.filter" style="font-size: 13px">
										{{ row.item.filter }}
										<button type="button" class="close small ml-3" aria-label="Close" style="font-size: 14px" @click="row.item.filter = ''">
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
						<tr v-for="(nb, d) in row.item.diseases" :key="d" @click="row.item.filter = d" :class="row.item.filter === d ? 'pointer table-active' : 'pointer'">
							<td>{{ d }}</td>
							<td>{{ nb }}</td>
						</tr>
					</tbody>
				</table>
			</b-card>
		</div>

		<div class="col-8">
			<b-card>
				<h6 class="card-subtitle mb-2 text-muted">
					Evidences
					<span class="float-right badge badge-primary" v-if="row.item.filter" style="font-size: 13px">
										{{ row.item.filter }}
											<button type="button" class="close small ml-3" aria-label="Close" style="font-size: 14px" @click="row.item.filter = ''">
													<span aria-hidden="true">&times;</span>
											</button></span>
				</h6>
				<table class="table table-sm">
					<tr>
						<th>Disease</th>
						<th>Evidence Type</th>
						<th>Clinical Significance</th>
						<th>{{ row.item.source === "CIViC" ? "Score level" : "Tier level" }}</th>
						<th>Drug</th>
						<th>References</th>
					</tr>
					<tr v-for="(c, idx) in filterClinical( row.item.clinical, row.item.filter )" :key="idx">
						<td>
							<a v-if="c.evidence_url" :href="c.evidence_url" target="_blank">{{ c.disease }}</a>
							<span v-else>{{ c.disease }}</span>
						</td>
						<td>{{ c.type }}</td>
						<td>{{ c.significance }}</td>
						<td>{{ c.tier }}</td>
						<td>{{ normalizeItemList(c.drug) }}</td>
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
import {normalizeItemList} from "@/utils";

export default {
	name: "GenericRowDetails",
	props: {
		row: {type: Object, required: true}
	},
	methods: {
		filterClinical(data, filter) {
			if (!filter) return data;
			return _.filter(data, d => {
				return d.disease === filter;
			});
		},
		normalizeItemList
	}
}
</script>

<style scoped>

</style>
