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
				<h5 class = "card-title">{{gene.symbol}}: {{phenotypes.length}} SVIP variants</h5>
				<h6 v-if='gene.oncogene'>Oncogene</h6>
				<!-- <p class = 'card-text'>{{gene.name}}</p> -->
				<dl class = 'row'>
					<dt class = 'col-2 text-right'>Entrez ID</dt>
					<dd class = 'col-10'>{{gene.entrez_id}}</dd>
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

		<div class = 'container-fluid'>
			<b-table :fields = 'fields' :items = 'phenotypes' :sort-by.sync="sortBy" :sort-desc='true' :filter='tableFilter'>
				<template slot="action" slot-scope="data">
				        <!-- We use @click.stop here to prevent a 'row-clicked' event from also happening -->
				        <b-button size="sm" @click.stop="showVariant(data.item.variant_id)">
				          Show Details
				        </b-button>
				 </template>
			</b-table>
		</div>
	</div>

</div>
</template>

<script>

import Vue from 'vue'
import {HTTP} from '@/router/http'
import {serverURL} from '@/app_config'
// import geneVariants from '@/components/Variants'
import { mapGetters } from 'vuex'
import store from '@/store'
export default {
  data () {
    return {
      gene: {
        entrez_id: null,
        symbol: '',
        variants: []
      },
      confirmDeletion: false,
      itemsByPages: 10,
      itemsValue: [5, 10, 50, 100],
      fields: [
        {
          key: 'variant_name',
          label: 'Name',
          sortable: true
        }, {
          key: 'HGVScoding',
          label: 'HGVS coding',
          sortable: true
        }, {
          key: 'HGVSprotein',
          label: 'HGVS protein',
          sortable: true
        }, {
          key: 'position',
          label: 'Position',
          sortable: true
        }, {
          key: 'molecular_consequence',
          label: 'Molecular consequence',
          sortable: true
        },
        {
          key: 'tier_level',
          label: 'Tier Level',
          sortable: true
        },
        {
          key: 'SVIP_status',
          label: 'Status',
          sortable: true
        },
        {
          key: 'SVIP_confidence_score',
          label: 'Score',
          sortable: true
        },
        {
          key: 'action',
          label: '',
          sortable: false
        }
      ],
      sortBy: 'SVIP_confidence_score',
      tableFilter: ''
    }
  },
  computed: {
    ...mapGetters({
      variants: 'variants',
      rawPhenotypes: 'phenotypes',
      geneVariants: 'geneVariants',
      svipVariants: 'svipVariants'
    }),
    synonyms () {
      if (this.gene.geneAliases === undefined) return ''
      return this.gene.geneAliases.join(', ')
    },
    phenotypes () {
      let vm = this
      let variants = _.filter(this.svipVariants, v => { return v.gene_name == vm.gene.symbol })
      // _.forEach(this.svipVariants,g => {
      // 	console.log(g);
      // 	let variant = {
      // 		id: g.variant_id,
      // 		name: g.name,
      // 		type: g.so_name,
      // 		sources: g.sources.join("; "),
      // 		cancerTypes: '',
      // 		Drugs: '',
      // 		levelOfEvidence: '',
      // 		nbArticles: '',
      // 		articles: []
      // 	};
      // 	variants.push(variant);
      // });
      return variants
    }
  },
  // components: {geneVariants: geneVariants},
  methods: {
    setgene (gene) {
      this.gene = Object.assign({}, this.gene, gene)
    },
    showVariant (id) {
      this.$router.push('/gene/' + this.$route.params.gene_id + '/variant/' + id)
    }
  },
  beforeRouteEnter (to, from, next) {
    if (to.params.gene_id != 'new') {
      HTTP.get('genes/' + to.params.gene_id).then(res => {
        var gene = res.data
        store.commit('SELECT_GENE', gene)
        next(vm => vm.setgene(gene))
        // store.dispatch('listGeneVariants',{gene: gene.symbol}).then(res => {
        // 	next(vm => vm.setgene(gene));
        // })
      })
    }
  },
  beforeRouteUpdate (to, from, next) {
    if (to.params.gene_id != 'new') {
      HTTP.get('genes/' + to.params.gene_id).then(res => {
        var gene = res.data
        store.commit('SELECT_GENE', gene)
        next(vm => vm.setgene(gene))
        // store.dispatch('listGeneVariants',{gene: gene.symbol}).then(res => {
        // 	next(vm => vm.setgene(gene));
        // })
      })
    }
  },
  created () {
    var vm = this
    store.dispatch('getGenes')
    store.dispatch('getVariants')
    store.dispatch('getPhenotypes')
    store.dispatch('getAssociations')
  }

}
</script>

<style>
.container, .container-fluid{
	margin-top: 20px;
}

</style>
