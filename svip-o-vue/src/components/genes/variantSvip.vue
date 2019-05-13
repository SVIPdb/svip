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
		<div class="card-body">
			<b-table :fields="fields" :items="variant.svip_data.diseases" :sort-by.sync="sortBy" :sort-desc="false">
				<template slot="actions" slot-scope="row">
					<div style="text-align: right;">
						<!-- We use @click.stop here to prevent a 'row-clicked' event from also happening -->
		        <b-button size="sm" @click="toggleRowDetails(row,'details')" class="mr-2" variant="primary" :pressed=" viewItems['details'].indexOf(row.index) > -1">
		          {{ viewItems['details'].indexOf(row.index) > -1 ? 'Hide' : 'Show'}} Details
		        </b-button>
		        <b-button size="sm" @click="toggleRowDetails(row,'curation')" class="mr-2" variant="success" :pressed=" viewItems['curation'].indexOf(row.index) > -1">
		          {{ viewItems['curation'].indexOf(row.index) > -1 ? 'Hide' : 'Show'}} Curation
		        </b-button>
		        <b-button size="sm" @click="toggleRowDetails(row,'samples')" class="mr-2" :pressed=" viewItems['samples'].indexOf(row.index) > -1">
		          {{ viewItems['samples'].indexOf(row.index) > -1 ? 'Hide' : 'Show'}} Samples
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

				<template slot='pathogenicity' slot-scope='data'>
					<div style="vertical-align: middle; display: inline-block;">
						<span v-if="data.item.pathogenicity">{{ data.item.pathogenicity }}</span>
						<span v-else class="unavailable">unavailable</span>
					</div>
				</template>

				<template slot="score" slot-scope="data">
					<icon :name="data.item.score < 1 ? 'regular/star' : 'star'" style="margin-right: 5px"></icon>
					<icon :name="data.item.score < 2 ? 'regular/star' : 'star'" style="margin-right: 5px"></icon>
					<icon :name="data.item.score < 3 ? 'regular/star' : 'star'" style="margin-right: 5px"></icon>
					<icon :name="data.item.score < 4 ? 'regular/star' : 'star'" style="margin-right: 5px"></icon>
				</template>

				<template slot="row-details" slot-scope="row">
					
					<b-card v-if="viewItems['details'].indexOf(row.index) > -1">
						<b-table :fields="evidenceFields" :items="row.item.evidences" :small="true">
							<template slot="reference" slot-scope="data">
								<PubmedPopover :pubmeta="{ pmid: data.value }" />
							</template>
						</b-table>
					</b-card>
					<b-card v-if="viewItems['curation'].indexOf(row.index) > -1">
						<p>curation</p>
					</b-card>
					<b-card v-if="viewItems['samples'].indexOf(row.index) > -1">
						<p>samples</p>
					</b-card>
					
					
					
				</template>
			</b-table>
		</div>
		<div class="card">
			<!-- TODO be specific for the disease -->
			<svipShowCuration :curationData="variant.svip_data.curation_entries"></svipShowCuration>
		</div>

	</div>
</template>


<script>
import ageDistribution from "@/components/plots/ageDistribution";
import genderBalance from "@/components/plots/genderBalance";
import genderBarPlot from "@/components/plots/genderBarPlot";
import genderPlot from "@/components/plots/genderPlot";
import {titleCase} from "../../utils";
import PubmedPopover from "@/components/widgets/PubmedPopover";
import svipShowCuration from "@/components/genes/svip/svipShowCuration";

export default {
	name: "VariantSVIP",
	components: {ageDistribution, PubmedPopover, genderPlot, svipShowCuration},
	props: {
		variant: {type: Object, required: true}
	},
	data() {
		return {
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
					key: 'pathogenicity',
					label: 'Pathogenicity',
					sortable: false
				},
				{
					key: "clinical_significance",
					label: "Clinical Significance",
					sortable: false
				},
				{
					key: "SVIP_status",
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
			evidenceFields: [
				{ key: "evidence_type", label: "Evidence Type", sortable: true },
				{ key: "clinical_significance", label: "Clinical Significance", sortable: true },
				{ key: "drug", label: "Drug", sortable: true },
				{ key: "tier_level", label: "Tier Level", sortable: true },
				{ key: "reference", label: "References", sortable: false },
			],
			viewItems: {
				curation: [],
				details: [],
				samples: []
			}
		};
	},
	methods: {
		titleCase,
		// svipShowCuration(row) {
		// 	console.log("row", row);
		// 	svipShowCuration;
		// },
		toggleRowDetails (row, type){
			let before = (this.viewItems['curation'].indexOf(row.index) > -1 || this.viewItems['samples'].indexOf(row.index) > -1 || this.viewItems['details'].indexOf(row.index) > -1);
			let idx = this.viewItems[type].indexOf(row.index);
			if (idx === -1) this.viewItems[type].push(row.index);
			else this.viewItems[type].splice(idx,1)
			let after = (this.viewItems['curation'].indexOf(row.index) > -1 || this.viewItems['samples'].indexOf(row.index) > -1 || this.viewItems['details'].indexOf(row.index) > -1);
			if (before != after) 	row.toggleDetails()
		}

	},
	computed: {
<<<<<<< HEAD
		data() {
			let items = this.variant.svip_data.diseases;
			_.forEach(items, i => {
				// i._showDetails = false;
				i.showRowDetails = false;
				i.showCuration = false;
				i.showSamples = false;
			})
			console.log("this.variant.svip_data.curation_entries", this.variant.svip_data.curation_entries)

			return items;
		},
=======
>>>>>>> 93b8550a298ec8ef6a7d99d6d0b2c6886570396c
		totalPatients() {
			return this.variant.svip_data.diseases.reduce((acc, x) => acc + x.nb_patients, 0);
		}
	}
};
</script>

<style scoped>
.container,
.container-fluid {
	margin-top: 20px;
}

svg.pathogenicity_level {
	margin-left: 50px;
}

rect.pathogenicity.expert {
	fill: #118644;
}

rect.pathogenicity.automatic {
	fill: #80fe07;
}
</style>
