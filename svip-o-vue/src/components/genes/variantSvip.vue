<template>
	<div class = 'card mt-3'>
		<div class = 'card-header'>
			<div class = 'card-title'>SVIP information <span class = 'text-danger float-right'>WARNING: fake data - only as a demo</span></div>
		</div>
		<div class = 'card-body'>
			<b-table :fields = 'fields' :items = 'data' :sort-by.sync="sortBy" :sort-desc='false'>				
			<template slot="actions" slot-scope="row">
				<b-button size="sm" @click.stop="row.toggleDetails">
				{{ row.detailsShowing ? 'Hide' : 'Show'}} Details
			</b-button>
		</template>
		<template slot='name' slot-scope='row'>
			<span :class="(row.detailsShowing)?'bold':''">{{row.item.name}}</span>
		</template>
		<template slot='age' slot-scope='data'>
			<age-distribution :data='data.item.age_distribution'></age-distribution>
		</template>
		<template slot='gender' slot-scope='data'>
			<gender-balance :data='data.item.gender_balance'></gender-balance>
		</template>
		<!-- <template slot='pathogenicity' slot-scope='data'>
			{{data.item.pathogenicity}} <svg height='16' width='16' style = 'margin-left: 20px' v-b-tooltip.hover :title="data.item.pathogenicity_level+' approved'"><rect x="0" y="0" width="16" height="16" :class="'pathogenicity '+data.item.pathogenicity_level" ></rect></svg>
			</template> -->
			<template slot='score' slot-scope='data'>
				<icon :name = "(data.item.score < 1)?'star-o':'star'" style='margin-right: 5px'></icon><icon :name = "(data.item.score < 2)?'star-o':'star'" style='margin-right: 5px'></icon><icon  :name = "(data.item.score < 3)?'star-o':'star'" style='margin-right: 5px'></icon><icon  :name = "(data.item.score < 4)?'star-o':'star'" style='margin-right: 5px'></icon>
			</template>
			<template slot="row-details" slot-scope="row">
				<div class="card">
					<div class="card-body" style = 'padding: 0'>
						<b-table :items='row.item.evidences' :small="true" ></b-table>
					</div>
				</div>
			</template>
		</b-table>
	</div>
</div>	
</template>

<script>

import { mapGetters } from 'vuex'
import ageDistribution from '@/components/plots/ageDistribution'
import genderBalance from '@/components/plots/genderBalance'
export default {
	name: 'public-databases-info',
	components: {ageDistribution,genderBalance},	
	data () {
		return {
			sortBy: 'name',
			fields: [
				{
					key: "name",
					label: 'Disease',
					sortable: true
				}, {
					key: 'nb_patients',
					label: "Nb of patients",
					sortable: true,
					class: 'text-center'
				}, {
					key: 'age',
					label: "Age distribution",
					sortable: false,
					class: 'text-center'
				}, {
					key: 'gender',
					label: "Gender balance",
					sortable: false,
					class: 'text-center'
				},
				{
					key: 'clinical_significance',
					label: "Clinical significance",
					sortable: false
				},
				{
					key: 'SVIP_status',
					label: "Status",
					sortable: false
				},
				{
					key: 'score',
					label: 'SVIP confidence',
					sortable: true,
					class: 'text-center'
				}, {
					key: 'actions',
					label: '',
					sortable: false
				}
			]
		}
	},
	methods: {
	},
	computed: {
		...mapGetters({
			variant: 'variant',
			svipVariant: 'svipVariant'
		}),
		data () {
			return this.svipVariant.diseases;
			
		}
	}
}
</script>

<style scoped>
.container, .container-fluid{
	margin-top: 20px;
}
.unavailable {
	font-style: italic;
	color: #ccc;
}
svg.pathogenicity_level{
	margin-left: 50px;
}
rect.pathogenicity.expert{
	fill: #107F40;
}
rect.pathogenicity.automatic{
	fill: #80FE07;
}
.bold{
	font-weight: bold;
}
</style>