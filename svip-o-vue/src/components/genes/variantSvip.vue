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
			<b-table :fields="fields" :items="data" :sort-by.sync="sortBy" :sort-desc="false">
				<template slot="actions" slot-scope="row">
					<div style="text-align: right;">
						<!-- We use @click.stop here to prevent a 'row-clicked' event from also happening -->
						<b-button size="sm" @click.stop="row.toggleDetails">
							{{ row.detailsShowing ? "Hide" : "Show" }} Details
						</b-button>
					</div>
				</template>
				<template slot="name" slot-scope="row">
                    <span :class="row.detailsShowing ? 'bold' : ''">{{
                        titleCase(row.item.name)
                    }}</span>
				</template>
				<template slot="age" slot-scope="data">
					<age-distribution :data="data.item.age_distribution"></age-distribution>
				</template>
				<template slot="gender" slot-scope="data">
					<gender-balance :data="data.item.gender_balance"></gender-balance>
				</template>

				<!--
        <template slot='pathogenicity' slot-scope='data'>
            {{data.item.pathogenicity}}
            <svg height='16' width='16' style='margin-left: 20px' v-b-tooltip.hover
                 :title="data.item.pathogenicity_level+' approval'">
                <rect x="0" y="0" width="16" height="16"
                      :class="'pathogenicity '+data.item.pathogenicity_level"></rect>
            </svg>
        </template>
        -->

				<template slot="score" slot-scope="data">
					<icon :name="data.item.score < 1 ? 'regular/star' : 'star'" style="margin-right: 5px"></icon>
					<icon :name="data.item.score < 2 ? 'regular/star' : 'star'" style="margin-right: 5px"></icon>
					<icon :name="data.item.score < 3 ? 'regular/star' : 'star'" style="margin-right: 5px"></icon>
					<icon :name="data.item.score < 4 ? 'regular/star' : 'star'" style="margin-right: 5px"></icon>
				</template>
				<template slot="row-details" slot-scope="row">
					<div class="card">
						<div class="card-body" style="padding: 0">
							<b-table :items="row.item.evidences" :small="true"></b-table>
						</div>
					</div>
				</template>
			</b-table>
		</div>
	</div>
</template>

<script>
import {mapGetters} from "vuex";
import ageDistribution from "@/components/plots/ageDistribution";
import genderBalance from "@/components/plots/genderBalance";
import {titleCase} from "../../utils";

export default {
	name: "public-databases-info",
	components: {ageDistribution, genderBalance},
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
				/* {
            key: 'pathogenicity',
            label: 'Pathogenicity',
            sortable: false
        }, */ {
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
			]
		};
	},
	methods: {
		titleCase
	},
	computed: {
		...mapGetters({
			variant: "variant",
			svipVariant: "svipVariant"
		}),
		data() {
			return this.svipVariant.diseases;
		}
	}
};
</script>

<style>
.container,
.container-fluid {
	margin-top: 20px;
}

.unavailable {
	font-style: italic;
	color: #ccc;
}

svg.pathogenicity_level {
	margin-left: 50px;
}

rect.pathogenicity.expert {
	fill: #107f40;
}

rect.pathogenicity.automatic {
	fill: #80fe07;
}

.bold {
	font-weight: bold;
}
</style>
