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

	<div class = 'card mt-3'>
		<div class = 'card-header'>
			<div class = 'card-title'>Main database information</div>
		</div>
		<div class = 'card-body'>
			<b-table :fields = 'fields' :items = 'data' :sort-by.sync="sortBy" :sort-desc='false'>
				<template slot='source' slot-scope='row'>
					<a :href='row.item.url' target = '_blank'>{{row.item.source}}</a>
				</template>
				<template slot='diseases' slot-scope='data'>
					{{Object.keys(data.item.diseases).length}} disease{{(Object.keys(data.item.diseases).length>1)?"s":""}}
				</template>
				<template slot='database_evidences' slot-scope='data'>
					{{data.item.database_evidences.length}} evidence{{(data.item.database_evidences.length>1)?"s":""}}
				</template>
				<template slot='clinical' slot-scope='data'>
					<span v-for='c in summaryClinical(data.item.clinical)' class = 'mr-2'>{{c}}</span>
				</template>
				<template slot='scores' slot-scope='data'>
					<score-plot :data='data.item.scores'></score-plot>
				</template>
				<template slot="actions" slot-scope="row">
				   <!-- We use @click.stop here to prevent a 'row-clicked' event from also happening -->
				   <b-button size="sm" @click.stop="row.toggleDetails">
				   		{{ row.detailsShowing ? 'Hide' : 'Show'}} Details
					</b-button>
				 </template>
				
			 	<template slot="row-details" slot-scope="row">
				  	<div class = 'row'>
						<div class="col-4">
							 <b-card>
							 <h6 class = 'card-subtitle mb-2 text-muted'>Diseases <i class = 'float-right' v-if='!row.item.filter'>click on a disease to filter the drugs table </i><span class = 'float-right badge badge-primary' v-if='row.item.filter' style = 'font-size: 13px'>{{row.item.filter}} <button type="button" class="close small ml-3" aria-label="Close" style = 'font-size: 14px' @click='row.item.filter=""'><span aria-hidden="true">&times;</span></button></span></h6>
							 	<table class = 'table table-sm table-hover'>
									<thead>
										<tr>
											<th>disease</th>
											<th># occcurences</th>
										</tr>
									</thead>
									<tbody>
										<tr v-for='(nb,d) in row.item.diseases' @click='row.item.filter=d' :class='(row.item.filter==d)?"pointer table-active":"pointer"'>
											<td>{{d}}</td>
											<td>{{nb}}</td>
										</tr>									
									</tbody>
								</table>
							 </b-card>
						</div>
						<div class="col-8">
							 <b-card >
							 <h6 class = 'card-subtitle mb-2 text-muted'>Drugs <span class = 'float-right badge badge-primary' v-if='row.item.filter' style = 'font-size: 13px'>{{row.item.filter}} <button type="button" class="close small ml-3" aria-label="Close" style = 'font-size: 14px' @click='row.item.filter=""'><span aria-hidden="true">&times;</span></button></span></h6>
							 <table class = 'table table-sm'>
							 	<tr>
									<th>Disease</th>
									<th>Drug</th>
									<th>Evidence Type</th>
									<th>Clinical significance</th>
									<th>Tier level</th>
								</tr>
								<tr v-for='c in filterClinical(row.item.clinical,row.item.filter)' >
									<td>{{c.disease}}</td>
									<td>{{c.drug}}</td>
									<td>{{c.type}}</td>
									<td>{{c.significance}}</td>
									<td>{{c.tier}}</td>
								</tr>
							 </table>
							 </b-card>
						</div>
					</div>
			 	  </b-card>
			 	</template>
				
			</b-table>
		</div>
	</div>	
</template>

<script>

import Vue from 'vue'
import { mapGetters } from 'vuex'
import store from '@/store'
import scorePlot from '@/components/plots/scorePlot'
export default {
	name: 'main-databases-info',
	components: {scorePlot},	
	data () {
		return {
			databases: {'civic': 'CIViC','cosmic': 'COSMIC','clinvar': 'ClinVar','oncokb': "oncoKB"},
			sortBy: 'source',
			fields: [
				{
					key: "source",
					label: 'Source',
					sortable: true
				}, {
					key: 'diseases',
					label: "Diseases",
					sortable: true
				}, {
					key: 'database_evidences',
					label: "Database Evidences",
					sortable: false
				}, {
					key: 'clinical',
					label: "Clinical significance / inerpretation",
					sortable: false
				}, {
					key: 'scores',
					label: "Confidence scores / review status",
					sortable: false
				}, {
					key: 'actions',
					label: '',
					sortable: false
				}
			]
		}
	},
	methods: {
		summaryClinical (data){
			return _.uniq(_.map(data,d => {return d.significance}))
		},
		filterClinical (data,filter){
			if (!filter) return data;
			return _.filter(data,d => {return d.disease == filter;});
			
		}
	},
	computed: {
		...mapGetters({
			variant: 'variant'
		}),
		data () {
			let data = {};
			_.forEach(this.variant.sources,s => {
				data[s] = {source: this.databases[s], source_id: '',diseases: [], database_evidences: [],clinical: [],scores: [],url: ''}
			});
			_.forEach(this.variant.association_set, a => {
				let source = a.source;
				let source_id = '';
				if (source == 'civic'){
					let test = a.source_link.match(/\/variants\/(\d+)/);
					if (test){
						source_id = test[1];
					}
				}
				data[source].diseases = data[source].diseases.concat(_.map(a.phenotype_set,a => {return a.term}));
				data[source].database_evidences = data[source].database_evidences.concat(_.map(a.evidence_set,e => {return e.description}));
				data[source].clinical.push({
					disease: _.map(a.phenotype_set,a => {return a.term}).join("; "),
					drug: a.drug_labels,
					significance: a.response_type,
					type: _.map(a.evidence_set,e => {return e.type}).join("; "),
					tier: '-'
				});
				data[source].scores.push(+a.evidence_level);
				data[source].source_id += source_id;
				data[source].url = a.source_url;
			})
			_.forEach(this.variant.sources,s => {
				data[s].diseases = _.countBy(data[s].diseases)
				data[s].diseases = _.fromPairs(_.sortBy(_.toPairs(data[s].diseases), 1).reverse())
				data[s].clinical = _.orderBy(data[s].clinical,c => {return c.disease});
				data[s]._showDetails = false;
				data[s].filter = '';
			});
			return Object.values(data);
		}
	}
}
</script>

<style>
.container, .container-fluid{
	margin-top: 20px;
}
.unavailable {
	font-style: italic;
	color: #ccc;
}
</style>