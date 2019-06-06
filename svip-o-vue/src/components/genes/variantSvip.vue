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
			<div class="card-title">
				SVIP Information
				<span class="text-danger float-right">WARNING: fake data - only as a demo</span>
			</div>
		</div>

		<div class="card-body top-level">
			<b-table :fields="fields" :items="svip_entries" :sort-by.sync="sortBy" :sort-desc="false">
				<template slot="actions" slot-scope="row">
					<div class="details-tray" style="text-align: right;">
						<!--
						<b-button v-access="'curators'" @click.stop="showPanel(row, 0)" size="sm" style="background-color:green;">
							Show Curation
						</b-button>
						<b-button v-access="'clinicians'" @click.stop="showPanel(row, 1)" size="sm" style="background-color:purple;">
							Show Samples
						</b-button>
						-->

						<!-- We use @click.stop here to prevent a 'row-clicked' event from also happening -->
						<b-button size="sm" @click.stop="row.toggleDetails">
							{{ row.detailsShowing ? "Hide" : "Show" }} Details
						</b-button>
					</div>
				</template>

				<template slot="name" slot-scope="row">
					<span :class="row.detailsShowing ? 'bold' : ''">{{ titleCase(row.item.name) }}</span>
				</template>

				<template slot="age" slot-scope="data">
					<age-distribution :data="data.item.age_distribution"></age-distribution>
				</template>

				<template slot="gender" slot-scope="data">
					<gender-plot :data="data.item.gender_balance"></gender-plot>
				</template>

				<template slot='pathogenic' slot-scope='data'>
					<div style="vertical-align: middle; display: inline-block;">
						<span v-if="data.value">{{ data.value }}</span>
						<span v-else class="unavailable">unavailable</span>
					</div>
				</template>

				<template slot="score" slot-scope="data">
					<div style="white-space: nowrap;">
						<icon v-for="score in [1,2,3,4]" :key="score" :name="data.item.score < score ? 'regular/star' : 'star'" style="margin-right: 5px" />
					</div>
				</template>

				<template slot="HEAD_actions">
					<div style="text-align: right; padding-right: 5px; display: none;">
						<b-button
							size="sm" variant="success" :class="`expander-button ${isAllExpanded ? 'is-expanded' : ''}`"
							@click.stop="() => setAllExpanded(!isAllExpanded)"
						>{{ isAllExpanded ? "Collapse All" : "Expand All"}}</b-button>
					</div>
				</template>


				<template slot="row-details" slot-scope="row">
					<div class=" row-details">
						<b-card no-body>
							<b-tabs v-model="svip_entry_tabs[row.item.name]" card :class="`svip-details-tabs selected-tab-${svip_entry_tabs[row.item.name]}`">

								<b-tab title="Evidence" active>
									<b-card-text>
										<b-table :fields="subtables.evidence.fields" :items="row.item.curation_entries" :show-empty="true" :small="true">
											<template slot="references" slot-scope="data">
												<VariomesLitPopover
													:pubmeta="{ pmid: trimPrefix(data.value, 'PMID:') }" :variant="variant.name" :gene="variant.gene.symbol" :disease="row.item.name"
												/>
											</template>

											<template slot="empty">
												<div class="empty-table-msg">- no evidence items -</div>
											</template>
										</b-table>
									</b-card-text>
								</b-tab>

								<b-tab title="Samples" :disabled="!(groups && groups.includes('clinicians'))">
									<b-card-text>
										<b-table
											v-if="(groups && groups.includes('clinicians'))"
											:fields="subtables.samples.fields"
											:items="getSampleProvider(row)"
											:small="true"
											:show-empty="true"
											class="table-sm filter-table"
											:api-url="row.item.samples_url"
											:per-page="dMeta(row).perPage"
											:current-page="dMeta(row).currentPage"
											:filter="packedFilter(dMeta(row).currentFilter)"
										>
											<template slot="contact" slot-scope="entry">
												<b-button :href="`${entry.value}?subject=Regarding Sample ID ${entry.item.sample_id}`" size="sm" variant="info">Contact</b-button>
											</template>

											<template slot="sample_tissue" slot-scope="entry">
												<a href="#" @click.stop="() => changeSubpanel(entry, 'tumor')">
													{{ entry.value }}
												</a>
											</template>

											<template slot="sequencing_date" slot-scope="entry">
												<a href="#" @click.stop="() => changeSubpanel(entry, 'sequencing')">
													{{ entry.value }}
												</a>
											</template>

											<template slot="empty">
												<div class="empty-table-msg">- no samples -</div>
											</template>

											<template slot="row-details" slot-scope="entry">
												<div v-if="entry.item.curSubtable === 'tumor'" class="sample-subtable tumor-subtable">
													<table>
														<tr><th v-for="field in subtables.samples.tumor_fields" :key="field.key">{{ field.label }}</th></tr>
														<tr><td v-for="field in subtables.samples.tumor_fields" :key="field.key">{{ entry.item[field.key] }}</td></tr>
													</table>
												</div>
												<div v-else-if="entry.item.curSubtable === 'sequencing'" class="sample-subtable sequencing-subtable">
													<table>
														<tr><th v-for="field in subtables.samples.sequencing_fields" :key="field.key">{{ field.label }}</th></tr>
														<tr><td v-for="field in subtables.samples.sequencing_fields" :key="field.key">{{ entry.item[field.key] }}</td></tr>
													</table>
												</div>
											</template>
										</b-table>

										<div class="paginator-holster">
											<b-pagination
												v-if="dMeta(row).totalRows > dMeta(row).perPage"
												v-model="dMeta(row).currentPage"
												:total-rows="dMeta(row).totalRows"
												:per-page="dMeta(row).perPage"
											/>
										</div>
									</b-card-text>
								</b-tab>

							</b-tabs>
						</b-card>
					</div>
				</template>
			</b-table>
		</div>
	</div>
</template>


<script>
import Vue from 'vue';
import store from '@/store';
import {titleCase} from "../../utils";
import PubmedPopover from "@/components/widgets/PubmedPopover";

import ageDistribution from "@/components/plots/ageDistribution";
import genderPlot from "@/components/plots/genderPlot";

import {makeSampleProvider} from "./item_providers/sample_provider";
import VariomesLitPopover from "@/components/widgets/VariomesLitPopover";
import {trimPrefix} from "@/utils";

Vue.component("pass", {
	render() {
		return this.$scopedSlots.default(this.$attrs);
	}
});

export default {
	name: "VariantSVIP",
	components: {ageDistribution, VariomesLitPopover, genderPlot},
	props: {
		variant: {type: Object, required: true}
	},
	data() {
		// create a per-disease structure to store sample-table paging and filtering settings
		const sample_meta = this.variant.svip_data.diseases.reduce((acc, entry) => {
			acc[entry.name] = {
				name: entry.name,
				totalRows: entry.nb_patients,
				sortBy: "disease",
				currentFilter: {},
				currentPage: 1,
				perPage: 10,
			};
			return acc;
		}, {});

		return {
			// we're storing the selected tab per disease so that we can manipulate the selection with the per-disease buttons
			// FIXME: (which, incidentally, aren't even being displayed right now...maybe we just remove this?)
			svip_entry_tabs: this.variant.svip_data.diseases.reduce((acc, x) => {
				// map each entry in the SVIP table by ID to a selected tab for that entry (e.g., evidence or samples)
				// by default, it'll be the first tab (evidence)
				acc[x.name] = 0;
				return acc;
			}, {}),

			svip_entries: this.variant.svip_data.diseases.map(x => ({
				_showDetails: false,
				...x
			})),

			sortBy: "name",
			fields: [
				{
					key: "name",
					label: "Disease",
					sortable: true
				},
				{
					key: "nb_patients",
					label: "# of Patients",
					formatter: x => `${x}/${this.totalPatients}`,
					sortable: true,
					class: "text-center"
				},
				{
					key: "age",
					label: "Age Distribution",
					sortable: false,
					class: "text-center"
				},
				{
					key: "gender",
					label: "Gender Balance",
					sortable: false,
					class: "text-center"
				},
				{
					key: 'pathogenic',
					label: 'Pathogenicity',
					sortable: false
				},
				{
					key: "clinical_significance",
					label: "Clinical Significance",
					sortable: false
				},
				{
					key: "status",
					label: "Status",
					sortable: false
				},
				{
					key: "score",
					label: "SVIP Confidence",
					sortable: true,
					class: "text-center"
				},
				{
					key: "actions",
					label: "",
					sortable: false
				}
			],
			subtables: {
				samples: {
					fields: [
						{ key: "disease_name", label: "Disease", sortable: true },
						{ key: "sample_id", label: "Sample ID", sortable: true },
						{ key: "year_of_birth", label: "Year of birth", sortable: true },
						{ key: "gender", label: "Gender", sortable: true },
						{ key: "hospital", label: "Hospital", sortable: true },
						{ key: "medical_service", label: "Medical Service", sortable: true },
						{ key: "contact", label: "Contact", sortable: true },
						{ key: "provider_annotation", label: "Provider Annotation", sortable: true },

						{ key: "sample_tissue", label: "Tumor Sample", sortable: true }, /* links to tumor details */
						{ key: "sequencing_date", label: "Sequencing Date", sortable: true },  /* links to sequencing details */
					],

					tumor_fields: [
						{ key: "tumor_purity", label: "Tumor Purity", sortable: true },
						{ key: "tnm_stage", label: "TNM Stage", sortable: true },
						{ key: "sample_type", label: "Sample Type", sortable: true },
						{ key: "sample_site", label: "Sample Site", sortable: true },
						{ key: "specimen_type", label: "Specimen Type", sortable: true }
					],

					sequencing_fields: [
						{ key: "sequencing_date", label: "Sequencing Date", sortable: true },
						{ key: "platform", label: "Platform", sortable: true },
						{ key: "panel", label: "Panel", sortable: true },
						{ key: "coverage", label: "Coverage", sortable: true },
						{ key: "calling_strategy", label: "Calling Strategy", sortable: true },
						{ key: "caller", label: "Caller", sortable: true },
						{ key: "aligner", label: "Aligner", sortable: true },
						{ key: "software", label: "Software", sortable: true },
						{ key: "software_version", label: "Software Version", sortable: true },
					],
					diseases_meta: sample_meta,
				},

				evidence: {
					fields: [
						{ key: "type_of_evidence", label: "Evidence Type", sortable: true },
						{ key: "effect", label: "Effect", sortable: true },
						{ key: "drug", label: "Drug", sortable: true },
						{ key: "tier_level_criteria", label: "Tier Criteria", sortable: true },
						{ key: "mutation_origin", label: "Mutation Origin", sortable: true },
						{ key: "summary", label: "Complementary Information", sortable: false },
						{ key: "support", label: "Support", sortable: true },
						{ key: "references", label: "References", sortable: false },
					]
				}
			}
		};
	},
	methods: {
		samplesFetched(target) {
			return ({ count }) => {
				target.totalRows = count;
			};
		},
		packedFilter(filters) {
			return JSON.stringify(filters);
		},
		dMeta(row) {
			return this.subtables.samples.diseases_meta[titleCase(row.item.name)];
		},
		showPanel(row, tabIndex) {
			console.log(`Switching row ${row.item.name} from tab ${this.svip_entry_tabs[row.item.name]} to tab ${tabIndex}`);
			// if we're switching to a new tab, always show the details; if it's the same tab, toggle it
			if (this.svip_entry_tabs[row.item.name] === tabIndex) {
				row.item._showDetails = !row.item._showDetails;
			}
			else {
				row.item._showDetails = true;
			}
			this.svip_entry_tabs[row.item.name] = tabIndex;
		},
		setAllExpanded(isExpanded) {
			this.variant.svip_data.diseases.forEach(x => {
				x._showDetails = isExpanded;
			});
		},
		titleCase,
		trimPrefix,
		getSampleProvider(row) {
			return makeSampleProvider(this.samplesFetched(this.dMeta(row)), {
				_showDetails: false,
				curSubtable: null
			});
		},
		changeSubpanel(entry, subpanel_id) {
			entry.item._showDetails = (entry.item.curSubtable === subpanel_id) ? !entry.item._showDetails : true;
			entry.item.curSubtable = subpanel_id;
		}
	},
	computed: {
		totalPatients() {
			return this.variant.svip_data.diseases.reduce((acc, x) => acc + x.nb_patients, 0);
		},
		groups() {
			return store.getters.groups;
		},
		isAllExpanded() {
			return this.variant.svip_data.diseases.every(x => x._showDetails);
		}
	}
};
</script>

<style scoped>
svg.pathogenicity_level {
	margin-left: 50px;
}

rect.pathogenicity.expert {
	fill: #118644;
}

rect.pathogenicity.automatic {
	fill: #80fe07;
}

.tab-pane.card-body {
	padding: 10px 0 0 0;
}

.paginator-holster {
	padding-left: 15px;
}

.expander-button {
	width: 100px;
	border: solid 1px #eee;
	background: #eee;
}
.expander-button.is-expanded {
	opacity: 0.5;
}
</style>

<style>
/*.svip-details-tabs .card-header {background-color: #ccc;}*/

/*.svip-details-tabs { border: solid 2px #aaa; border-radius: 5px; }*/

.svip-details-tabs.selected-tab-0 .card-header {background-color: #8bd4c2;}
.svip-details-tabs.selected-tab-1 .card-header {background-color: #c8bcca;}

.svip-details-tabs .card-header a.nav-link.active { color: black; }
.svip-details-tabs .card-header a.nav-link { color: #637fb0; }

.nav-tabs .nav-item { margin-right: 3px; }
.nav-tabs .nav-item .nav-link { padding: 5px 20px 8px; }
</style>
