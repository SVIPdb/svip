/* eslint-disable */
<template>
	<div class = 'container'>
		<div class="highlight-clean">
			<div class="container">
				<div class="intro section text-center">
					<!-- <h2 class="text-center">SVIP-O</h2>
					<p class="text-center">Swiss Variant Interpretation Platform for Oncology </p> -->
					<img src="../assets/svip_logo.png" width="368" height="137" alt="Svip Logo">
				</div>
				<div class = 'section row justify-content-md-center'>
					<div class = 'col-6'>
						<!-- <form ><input type="search" placeholder="Search for gene / variant" class="form-control" /></form> -->
						<form>
							<v-select :options="options" value='' placeholder="Search for gene / variant" v-model="gene"></v-select>
					</form>
				</div>
			</div>
				
			<div class = 'section stats row justify-content-md-center'>
				<div class = 'col'>
					<h3>{{genes.length}} Genes</h3>
				</div>
				<div class = 'col'>
					<h3>{{variants.length}} Alterations</h3>
				</div>
				<div class = 'col'>
					<h3>5 Tumor types</h3>
				</div>
			</div>
				
		</div>
	</div>
</div>
</template>

<script>

import { mapGetters } from 'vuex'
import store from '@/store'
export default {
	name: 'home',
	data () {
		return {
			gene: {}
		}
	},
	watch: {
		gene: function(n,o){
			if (n.value){
				this.$router.push("gene/"+n.value)
			}
		}	
	},
	computed: {
  	  ...mapGetters({
  	  	  genes: 'genes',
		  variants: 'variants'
  	    }),
		project () {
			return this.user.projects.filter(p => p.project_id == this.user.project_id)[0];
		},
		options () {
			return this.genes.map(g => {return {label: g.hugoSymbol, value: g.entrezGeneId}});
		}
	},
	methods: {
		test (val) {
			console.log(val);
		}
	},
	created (){
		var vm = this;
		store.dispatch('getGenes');
		store.dispatch('getVariants');

	}
	
}


</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.section{
	margin-top: 60px;
}
.intro{
	margin-top: 120px;
}
.stats{
	text-align: center;
}

.d-center {
  display: flex;
  align-items: center;
}

.selected img {
  width: auto;
  max-height: 23px;
  margin-right: 0.5rem;
}
</style>
/* eslint-disable */