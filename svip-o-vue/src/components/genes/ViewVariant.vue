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
	<div class = 'card'>
		<div class = 'card-body'>
			<table class = 'table'>
				<tr>
					<th>Gene Name</th>
					<th>Variant</th>
					<th>Variant HGVS.c</th>
					<th>Variant HGVS.p</th>
					<th>dbSNP</th>
					<th>Molecular consequence</th>
					<th>Position</th>
					<th>Ref. Genome</th>
				</tr>
				<tr>
					<td><b><router-link :to='"/gene/"+gene_id'>{{variant.gene.symbol}}</router-link></b></td>
					<td><b>{{variant.name}}</b></td>
					<td class = 'unavailable'>unavailable</td>
					<td class = 'unavailable'>unavailable</td>
					<td class = 'unavailable'>unavailable</td>
					<td>{{variant.so_name}}</td>
					<td class = 'unavailable'>unavailable</td>
					<td class = 'unavailable'>unavailable</td>

				</tr>
			</table>
		</div>
	</div>
	
	<variant-main-databases></variant-main-databases>
	
</div>
</template>

<script>

import Vue from 'vue'
import {HTTP} from '@/router/http'
// import geneVariants from '@/components/Variants'
import { mapGetters } from 'vuex'
import variantMainDatabases from '@/components/genes/variantMainDatabases'
import store from '@/store'
export default {
	data () {
		return {
			fields: ['pmid','authors','title','pubDate','journal','elocationId'],
		}
	},
	components: {variantMainDatabases},
	computed: {
		...mapGetters({
			variant: 'variant',
			gene: 'gene'
		}),
		synonyms () {
			if (this.gene.geneAliases === undefined) return '';
			return this.gene.geneAliases.join(", ");
		},
		gene_id () {
			let test = this.variant.gene.url.match(/genes\/(\d+)/);
			if (test) return test[1];
			return '';
		}
	},
	// components: {geneVariants: geneVariants},
	methods: {
	},
	beforeRouteEnter (to, from, next) {
		if (to.params.gene_id != 'new'){
			HTTP.get('genes/'+to.params.gene_id).then(res => {
				var gene = res.data;
				store.commit('SELECT_GENE',gene);
				store.dispatch('getGeneVariant',{gene: gene.symbol,variant: to.params.variant_id}).then(res => {
					next();
				})
			});			
		}
	},
	beforeRouteUpdate (to, from, next) {
		if (to.params.gene_id != 'new'){
			HTTP.get('genes/'+to.params.gene_id).then(res => {
				var gene = res.data;
				store.commit('SELECT_GENE',gene);
				store.dispatch('getGeneVariant',{gene: gene.symbol,variant: to.params.variant_id}).then(res => {
					next();
				})
			});			
		}
  },
	created (){

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