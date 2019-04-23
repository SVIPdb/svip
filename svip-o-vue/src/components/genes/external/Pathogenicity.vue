<template>
	<div class="col-sm-auto">
		<div class="card mt-3">
			<div class="card-header">
				<div class="card-title">Algorithmic Impact Prediction</div>
			</div>

			<div class="card-body">
				<b-table :fields="fields" :items="items" :sort-by.sync="sortBy" :sort-desc="false">
					<template slot="actions" slot-scope="row">
						<!-- We use @click.stop here to prevent a 'row-clicked' event from also happening -->
						<b-button size="sm" @click.stop="row.toggleDetails">
							{{ row.detailsShowing ? "Hide" : "Show" }} Details
						</b-button>
					</template>
					<template slot="name" slot-scope="row">
						{{ row.item.name }}
					</template>
				</b-table>
			</div>
		</div>
	</div>
</template>

<script>
import {desnakify, titleCase} from "@/utils";
import round from 'lodash/round';

function deref_path(target, path) {
	return path.split('.').reduce((acc, x) => acc ? acc[x] : null, target);
}

const sources = [
	{name: "SIFT", path: "cadd.sift", score: 'val', impact: 'cat'},
	{name: "Polyphen", path: "cadd.polyphen", score: 'val', impact: 'cat'},
	// {name: "FATHMM", path: "dbnsfp.fathmm", score: 'score', impact: 'pred'},
	{name: "FATHMM", path: "extras", score: 'fathmm_score', impact: 'fathmm_prediction'},
];

export default {
	name: "Pathogenicity",
	data() {
		return {
			sortBy: "",
			items: (
				sources
					.filter(source => deref_path(this, source.path))
					.map(
						source => {
							const extracted = deref_path(this, source.path);
							return {
								source: source.name,
								score: round(parseFloat(extracted[source.score]), 3),
								impact: desnakify(extracted[source.impact], true)
							};
						}
					)
			),
			fields: [
				{
					key: "source",
					label: "Source",
					sortable: true
				},
				{
					key: "score",
					label: "Score",
					sortable: true
				},
				{
					key: "impact",
					label: "Impact",
					sortable: true
				}
			]
		};
	},
	props: ["cadd", "dbnsfp", "extras"]
};
</script>

<style scoped></style>
