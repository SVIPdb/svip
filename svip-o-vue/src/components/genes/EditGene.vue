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

<template>
<div class = 'container'>
	<h3>Genes</h3>
	<form name = 'formGene' @submit.prevent = 'submitGene()'>
		<div class = 'card'>
			<div class = 'card-header'>
				<div class = 'card-title'>
					<span v-if = 'gene.gene_id === -1'>New gene</span>
					<span v-if = 'gene.gene_id > -1'>{{gene.name}}</span>
				</div>
			</div>
			<div class = 'card-body'>
				<fieldset>
					<legend>Name and description</legend>
					<div class="form-group row" :class="{'has-error': errors.has('name') }">
						<label for="name" class="col-sm-3 control-label text-right">Name</label>
						<div class="col-sm-9 text-left">
							<input type="text" class="form-control" id="name" name = 'name' v-model = 'gene.name' placeholder="Experiment name"  v-validate="'required'"><span>{{errors.first('name')}}</span>
						</div>
					</div>
					<div class="form-group row">
						<label for="description" class="col-sm-3 control-label text-right">Description</label>
						<div class="col-sm-9">
							<textarea name = 'description' v-model = 'gene.description' class="form-control" rows="5" placeholder = 'Experiment description'></textarea>
						</div>
					</div>

				</fieldset>

			</div>
			<div class = 'card-footer'>
				<div class = 'row'>
					<div class = 'col-sm-10 col-sm-offset-2 text-center'>
						<button type = 'submit' class = 'btn btn-success' :disabled='!gene.name||errors.any()'>Submit</button>
						<a :href="(gene.gene_id == -1)?'/gene':'/gene/'+gene.gene_id" class="btn btn-link">Cancel</a>
					</div>

				</div>
			</div>
		</div>
	</form>
</div>
</template>

<script>

import Vue from 'vue'
import {HTTP} from '@/router/http'
import { mapGetters } from 'vuex'
import VeeValidate from 'vee-validate'

Vue.use(VeeValidate, {fieldsBagName: 'formFields'})

export default {
  data () {
    return {
      permissions: [],
      gene: {
        gene_id: -1,
        name: '',
        description: '',
        user_id: '',
        user_name: ''
      }
    }
  },
  methods: {
    submitExperiment () {
      var vm = this
      if (vm.gene.gene_id == -1) {
        HTTP.post('gene', vm.gene).then(res => {
          var gene = res.data
          vm.$snotify.success('gene created successfuly', 'SUCCESS')
          vm.$router.push('/gene/' + gene.gene_id)
        })
      } else {
        HTTP.put('gene', vm.gene).then(res => {
          var gene = res.data
          vm.$snotify.success('gene updated successfuly', 'SUCCESS')
          vm.$router.push('/gene/' + gene.gene_id)
        })
      }
    }
  },
  computed: {
  	  ...mapGetters({
  	  	  user: 'currentUser'
  	    })

  },

  created () {
    if (this.$route.params.gene_id != 'new') {
      this.gene.gene_id = this.$route.params.gene_id
      HTTP.get('gene/' + this.gene.gene_id).then(res => {
        var gene = res.data
        this.gene = Object.assign({}, this.gene, gene)
      })
    } else {
      this.gene.user_id = this.user.user_id
      this.gene.user_name = this.user.username
    }
  }
}

</script>
