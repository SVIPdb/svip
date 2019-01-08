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
				<h5 class = "card-title">{{gene.hugoSymbol}}: {{alteration.name}}</h5>
				<h6 v-if='gene.oncogene'>Oncogene</h6>
				<p class = 'card-text'>{{gene.name}}</p>
				<dl class = 'row'>
					<dt class = 'col-2 text-right'>Synonyms</dt>
					<dd class = 'col-10'>{{synonyms}}</dd>
				</dl>
				<hr>
				<dl class = 'row'>
					<dt class = 'col-2 text-right'>Level of Evidence</dt>
					<dd class = 'col-10'>{{alteration.levelOfEvidence}}</dd>
					<dt class = 'col-2 text-right'>Consequence</dt>
					<dd class = 'col-10'>{{alteration.consequence.description}} <span v-if="alteration.consequence.isGenerallyTruncating">This alteration is generally truncating the protein</span></dd>
					<dt class = 'col-2 text-right'>Cancer Type</dt>
					<dd class = 'col-10'>{{alteration.cancerType}}</dd>
					<dt class = 'col-2 text-right'>Description</dt>
					<dd class = 'col-10'>{{alteration.description}}</dd>
					<dt class = 'col-2 text-right'>Type of Evidence</dt>
					<dd class = 'col-10'>{{alteration.evidenceType}}</dd>
					<dt class = 'col-2 text-right'>Known Effect</dt>
					<dd class = 'col-10'>{{alteration.knownEffect}}</dd>
					<dt class = 'col-2 text-right'>Drugs</dt>
					<dd class = 'col-10'>{{alteration.drugs.join(", ")}}</dd>
				</dl>
			</div>
		</div>
	</div>
	
	<div class = 'container-fluid' v-if='alteration.articles.length'>
		<h4>References</h4>
	<b-table :fields = 'fields' :items = 'alteration.articles'>
	</b-table>
	
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
			fields: ['pmid','authors','title','pubDate','journal','elocationId'],
		}
	},
	computed: {
		...mapGetters({
			rawAlterations: 'alterations'
		}),
		synonyms () {
			if (this.gene.geneAliases === undefined) return '';
			return this.gene.geneAliases.join(", ");
		},
		levelAlterations () {
			return this.alterations.filter(a => {return a.levelOfEvidence});
		},
		alteration () {
			let alteration = _.filter(this.rawAlterations, a => {return a.id == this.$route.params.variant_id;});
			if (!alteration.length) return {
				name: '',
				levelOfEvidence: '',
				consequence: {
					description: '',
					isGenerallyTruncating: ''
				},
				cancerType: '',
				description: '',
				articles: [],
				evidenceType: '',
				knownEffect: '',
				drugs: []
				
			};
			let alt = alteration[0];
			console.log(alt);
			let drugs = [];
			_.forEach(alt.treatments,t => {
				_.forEach(t.drugs,d => {
					drugs.push(d.drugName)
				})
			})
			return {
				name: alt.alterations[0].name,
				levelOfEvidence: alt.levelOfEvidence,
				consequence: {
					description: alt.alterations[0].description,
					isGenerallyTruncating: alt.alterations[0].isGenerallyTruncating
				},
				cancerType: alt.cancerType,
				description: alt.description,
				articles: alt.articles,
				evidenceType: alt.evidenceType,
				knownEffect: alt.knownEffect,
				drugs: drugs
			};
		}
	},
	// components: {geneVariants: geneVariants},
	methods: {
		setgene (gene) {
			this.gene = Object.assign({}, this.gene, gene);
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
		store.dispatch('getGenes').then(g => {
			store.dispatch('getAlterations',{gene_id: this.$route.params.gene_id})
		});
		store.dispatch('getVariants');

	}


}
</script>

<style>
.container, .container-fluid{
	margin-top: 20px;
}

</style>