<template>
	<!--
  /************************ LICENCE ***************************
  *     This file is part of <ViKM Vital-IT Knowledge Management web application>
  *     Copyright (C) <2016> SIB Swiss Institute of Bioinformatics
  *
  *     This program is free software: you can redistribute it and/or modify
  *     it under the terms of the GNU Affero General Public License as
  *     published by the Free Software Foundation, either version 3 of the
  *     License, or (at your option) any later version.
  *
  *     This program is distributed in the hope that it will be useful,
  *     but WITHOUT ANY WARRANTY; without even the implied warranty of
  *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  *     GNU Affero General Public License for more details.
  *
  *     You should have received a copy of the GNU Affero General Public License
  *    along with this program.  If not, see <http://www.gnu.org/licenses/>
  *
  *****************************************************************/
  -->

	<div class="card mt-3">
		<div class="card-header">
			<div class="card-title">Publicly Available Information</div>
		</div>

		<div class="card-body">
			<b-table :fields="fields" :items="data" :sort-by.sync="sortBy" :sort-desc="false">
				<template slot="source" slot-scope="row">
					<a :href="row.item.variant_url" target="_blank">{{ row.item.source.display_name }}</a>
				</template>

				<template slot="diseases" slot-scope="data">
					{{ Object.keys(data.item.diseases).length }} disease{{ Object.keys(data.item.diseases).length !== 1 ? "s" : "" }}
				</template>

				<template slot="publication_count" slot-scope="data">
						<component v-if="rowHasPart(data, 'publication_count')" :is="data.item.row_parts.publication_count" :row="data" />
						<span v-else>
						{{ data.value.toLocaleString() }} evidence{{ data.value !== 1 ? "s" : "" }}
						</span>
				</template>

				<template slot="clinical" slot-scope="data">
					<!--<span v-for='c in summaryClinical(data.item.clinical)' class='mr-2'>{{c}}</span>-->
					<component v-if="rowHasPart(data, 'clinical')" :is="data.item.row_parts.clinical" :row="data" />
					<significance-bar-plot :data="data.item.clinical_significances"></significance-bar-plot>
				</template>

				<template slot="scores" slot-scope="data">
						<component v-if="rowHasPart(data, 'scores')" :is="data.item.row_parts.scores" :row="data" />
						<score-plot v-else :data="data.item.scores"></score-plot>
				</template>

				<template slot="actions" slot-scope="row">
					<div style="text-align: right;">
						<!-- We use @click.stop here to prevent a 'row-clicked' event from also happening -->
						<b-button size="sm" @click.stop="row.toggleDetails">
							{{ row.detailsShowing ? "Hide" : "Show" }} Details
						</b-button>
					</div>
				</template>

				<template slot="row-details" slot-scope="row">
					<component v-if="row.item.details_part" :is="row.item.details_part" :row="row" />
					<GenericSourceDetailsRow v-else :row="row" />
				</template>
			</b-table>
		</div>
	</div>
</template>

<script>
import {mapGetters} from "vuex";
import {HTTP} from "@/router/http";
import scorePlot from "@/components/plots/scorePlot";
import significanceBarPlot from "@/components/plots/significanceBarPlot";
import {titleCase} from "@/utils";
import GenericSourceDetailsRow from "./sources/GenericRowDetails";
import {normalizeItemList} from "../../utils";
import CosmicRowDetails from "./sources/cosmic/CosmicRowDetails";
import CosmicScoresCol from "./sources/cosmic/CosmicScoresCol";

export default {
	name: "public-databases-info",
	components: {GenericSourceDetailsRow, scorePlot, significanceBarPlot},
	data() {
		return {
			databases: {
				civic: { source_name: "CIViC" },
				cosmic: {
					source_name: "COSMIC",
					row_parts: {
						scores: CosmicScoresCol
					},
					details_part: CosmicRowDetails
				},
				clinvar: { source_name: "ClinVar" },
				oncokb: { source_name: "OncoKB" }
			},
			sortBy: "source",
			fields: [
				{
					key: "source",
					label: "Source",
					sortable: true
				},
				{
					key: "diseases",
					label: "Diseases",
					sortable: true
				},
				{
					key: "publication_count",
					label: "Database Evidences",
					sortable: true
				},
				{
					key: "clinical",
					label: "Clinical Significance / Interpretation",
					sortable: false
				},
				{
					key: "scores",
					label: "Confidence Scores / Review Status",
					sortable: false
				},
				{
					key: "actions",
					label: "",
					sortable: false
				}
			]
		};
	},
	methods: {
		summaryClinical(data) {
			/*
      return _.uniq(_.map(data, d => {
          return d.significance
      }))
      */
			return _(data)
				.groupBy("clinical_significance")
				.map((items, name) => ({name, count: items.length}))
				.value();
		},
		filterClinical(data, filter) {
			if (!filter) return data;
			return _.filter(data, d => {
				return d.disease === filter;
			});
		},
		rowHasPart(row, part) {
			return row.item.row_parts && row.item.row_parts[part];
		normalizeItemList(items) {
			if (!items) return items;

			return items
				.split(",")
				.map(x => x.trim())
				.join(", ");
		},
		getAssociations(association_url) {
			return HTTP.get(association_url).then(res => {
				console.log("Queried ", association_url, " got: ", res);

				return res.data.results && res.data.results.map(a => ({
					disease: _.map(a.phenotype_set, a => {return titleCase(a.term);}).join("; "),
					drug: this.normalizeItemList(a.drug_labels),
					significance: a.response_type,
					type: _.map(a.evidence_set, e => {return e.type;}).join("; "),
					tier: a.evidence_level + a.evidence_label,
					publications: a.evidence_set.reduce(
						(acc, ev_set) =>
							acc.concat(
								ev_set.publications.map(p => {
									const pmid = _.last(p.split("/"));
									return {url: p, pmid: /^[0-9]+$/.test(pmid) ? pmid : "(external)"};
								})
							),
						[]
					)
				}))
			})
		}
	},
	props: {variant: {type: Object, required: true}},
	created() {
		/*
		this.variant.variantinsource_set.forEach(vis => {
			this.getAssociations(vis.associations_url).then((associations) => {
				this.associations[vis.source.name] = associations;
			})
		});
		*/
	},
	computed: {
		data() {
			/*
			let data = {};

			_.forEach(this.variant.sources, s => {
				data[s] = {
					...this.databases[s],
					diseases: [],
					database_evidences: [],
					clinical: [],
					scores: [],
					url: ""
				};
			});

			_.forEach(this.variant.association_set, a => {
				let source = a.source;

				data[source].diseases = data[source].diseases.concat(
					_.map(a.phenotype_set, a => {return titleCase(a.term);})
				);

				// builds the set of clinical_significance
				data[source].database_evidences = data[source].database_evidences.concat(
					_.map(a.evidence_set, e => {return e.description;})
				);

				// builds the list of evidence items associated with this entry
				data[source].clinical.push({
					disease: _.map(a.phenotype_set, a => {return titleCase(a.term);}).join("; "),
					drug: normalizeItemList(a.drug_labels),
					type: a.evidence_type,
					direction: a.evidence_direction,
					significance: a.clinical_significance,
					tier: a.evidence_level,
					evidence_url: a.source_link,
					publications: a.evidence_set.reduce(
						(acc, ev_set) =>
							acc.concat(
								ev_set.publications.map(p => {
									const pmid = _.last(p.split("/"));
									return {url: p, pmid: /^[0-9]+$/.test(pmid) ? pmid : "(external)"};
								})
							),
						[]
					),
					context: a.environmentalcontext_set && a.environmentalcontext_set.length > 0 && a.environmentalcontext_set[0]
				});

				data[source].scores.push(+a.evidence_level);
				data[source].url = a.source_url;
			});

			_.forEach(this.variant.sources, s => {
				data[s].diseases = _.countBy(data[s].diseases);
				data[s].diseases = _.fromPairs(
					_.sortBy(_.toPairs(data[s].diseases), 1).reverse()
				);

				data[s].clinical = _.orderBy(data[s].clinical, c => {
					return c.disease;
				});

				data[s]._showDetails = false;
				data[s].filter = "";
			});

			return Object.values(data);
			*/

			return this.variant.variantinsource_set.map(vis => {
				console.log(vis);

				return {
					...vis,
					clinical: this.getAssociations(vis.associations_url)
				}
			});
		}
	}
};
</script>

<style scoped>
.container,
.container-fluid {
	margin-top: 20px;
}
</style>
