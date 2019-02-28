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
import {titleCase} from "../../../utils";

const sources = [
	{name: "SIFT", key: "sift"},
	{name: "Polyphen", key: "polyphen"}
];

export default {
	name: "Pathogenicity",
	data() {
		return {
			sortBy: "",
			items: sources
				.filter(source => this.cadd[source.key])
				.map(source => ({
					source: source.name,
					score: this.cadd[source.key].val,
					impact: titleCase(
						this.cadd[source.key].cat.split("_").join(" ")
					)
				})),
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
	props: ["cadd"]
};
</script>

<style scoped></style>
