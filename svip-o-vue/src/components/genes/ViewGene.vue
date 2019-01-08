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

<div class = 'container-fluid'>
	<div class = 'container'>
		<div class = 'card'>
			<div class = 'card-body'>
				<h5 class = "card-title">{{gene.hugoSymbol}}: {{geneVariants.length}} alterations</h5>
				<h6 v-if='gene.oncogene'>Oncogene</h6>
				<p class = 'card-text'>{{gene.name}}</p>
				<dl class = 'row'>
					<dt class = 'col-2 text-right'>Synonyms</dt>
					<dd class = 'col-10'>{{synonyms}}</dd>
				</dl>
			</div>
		</div>
		
		<div class = 'container'>
			<div class = 'row'>
				<div class = 'col-6'>
        			<b-form-group horizontal label="Filter" class="mb-0">
        			  <b-input-group>
        			    <b-form-input v-model="tableFilter" placeholder="Type to Search" />
        			    <b-input-group-append>
        			      <b-btn :disabled="!tableFilter" @click="tableFilter = ''">Clear</b-btn>
        			    </b-input-group-append>
        			  </b-input-group>
        			</b-form-group>
				</div>
			</div>
		
		
		</div>
		
		<div class = 'container'>
			<b-table :fields = 'fields' :items = 'levelAlterations' :sort-by.sync="sortBy" :sort-desc='true' :filter='tableFilter'>
				<template slot='levelOfEvidence' slot-scope='data'>{{data.item.levelOfEvidence.replace("LEVEL_","")}}</template>
				<template slot="nbArticles" slot-scope="row">
					<b-button variant='link' @click.stop="row.toggleDetails">{{row.detailsShowing ? "Hide" : "Show" }} {{row.item.nbArticles}}</b-button>
				</template>
				<template slot="action" slot-scope="data">
				        <!-- We use @click.stop here to prevent a 'row-clicked' event from also happening -->
				        <b-button size="sm" @click.stop="showVariant(data.item.id)">
				          Show Details
				        </b-button>
				 </template>
				      <template slot="row-details" slot-scope="row">
				        <b-card>
				          <ul>
				            <li v-for="(value, key) in row.item.articles" :key="key">{{ value}}</li>
				          </ul>
				        </b-card>
				      </template>
			</b-table>
		</div>
	</div>

</div>
</template>

<script>

import Vue from 'vue'
import {HTTP} from '@/router/http'
// import geneVariants from '@/components/Variants'
import { mapGetters } from 'vuex'
import store from '@/store'
export default {
	data () {
		return {
			gene: {},
			confirmDeletion: false,
			itemsByPages: 10,
			itemsValue: [5,10,50,100],
			fields: [
				{
					key: 'name',
					label: 'Alteration',
					sortable: true
				},{
					key: 'cancerTypes',
					label: "Cancer Type",
					sortable: true
				},{
					key: 'drugs',
					label: 'Drugs',
					sortable: true
				},{
					key: 'levelOfEvidence',
					label: "Level",
					sortable: true
				},
				{
					key: 'nbArticles',
					label: "References",
					sortable: true
				} ,
				{
					key: 'action',
					label: '',
					sortable: false
				}
			],
			sortBy: 'nbArticles',
			tableFilter: ''
		}
	},
	computed: {
		...mapGetters({
			variants: 'variants',
			rawAlterations: 'alterations'
		}),
		synonyms () {
			if (this.gene.geneAliases === undefined) return '';
			return this.gene.geneAliases.join(", ");
		},
		geneVariants () {
			return this.variants.filter(v => { if (v.entrezGeneId == this.$route.params.gene_id) return v;});
		},
		levelAlterations () {
			return this.alterations.filter(a => {return a.levelOfEvidence});
		},
		alterations () {
			let vm = this;
			let alterations = [];
			_.forEach(vm.rawAlterations, d => {
					let id = d.id;
					let cancerType = d.cancerType;
					let drugs = [];
					let levelOfEvidence = d.levelOfEvidence;
					let articles = [];
					if (d.articles !== undefined) articles = d.articles.map(a => {return a.pmid+": "+a.title});

					if (d.treatments !== undefined){
						_.forEach(d.treatments,t => {
							if (t.drugs !== undefined){
								_.forEach(t.drugs, r => {
									if (r.drugName && drugs.indexOf(r.drugName) == -1) drugs.push(r.drugName)
								})
							}
						})
					}
					
					_.forEach(d.alterations, a => {	

						if (alterations[id] === undefined){
							let consequence = (a.consequence !== undefined && a.consequence.term !== undefined) ? a.consequence.term : '';
							alterations[id] = {
								id: id,
								cancerTypes: [d.cancerType],
								alterationType: a.alterationType,
								consequence: consequence,
								alteration: a.alteration,
								name: a.name,
								drugs: [drugs],
								levelOfEvidence: levelOfEvidence,
								articles: articles
							}
						}
						else {
							if (alterations[id].cancerTypes.indexOf(d.cancerType) == -1 && d.cancerType) alterations[id].cancerTypes.push(d.cancerType);
							_.forEach(drugs, r => {
								if (alterations[id].drugs.indexOf(r) == -1) alterations[id].drugs.push(r);
							})
							_.forEach(articles, a => {
								if (alterations[id].articles.indexOf(a) == -1) alterations[id].articles.push(a);
							})

						}					
				})
			})
			alterations = _.map(_.filter(_.values(alterations),a => {return a !== undefined}),d => {return {
				id: d.id,
				name: d.name,
				cancerTypes: d.cancerTypes.join(", "),
				drugs: d.drugs.join(", "),
				levelOfEvidence: d.levelOfEvidence,
				articles: d.articles,
				nbArticles: d.articles.length
				
			}})
			return alterations;
		}
	},
	// components: {geneVariants: geneVariants},
	methods: {
		setgene (gene) {
			this.gene = Object.assign({}, this.gene, gene);
		},
		showVariant (id){
			this.$router.push('/gene/'+this.$route.params.gene_id+"/variant/"+id)
		}
	},
	beforeRouteEnter (to, from, next) {
		if (to.params.gene_id != 'new'){
			HTTP.get('genes/'+to.params.gene_id).then(res => {
				var gene = res.data;
				next(vm => vm.setgene(gene));
			});			
		}
	},
	beforeRouteUpdate (to, from, next) {
		if (to.params.gene_id != 'new'){
			HTTP.get('genes/'+to.params.gene_id).then(res => {
				var gene = res.data;
				this.setgene(gene);
				next();
			});
		}
  },
	created (){
		var vm = this;
		store.dispatch('getGenes');
		store.dispatch('getVariants');
		store.dispatch('getAlterations',{gene_id: this.$route.params.gene_id});

	}


}
</script>

<style>
.container, .container-fluid{
	margin-top: 20px;
}

</style>