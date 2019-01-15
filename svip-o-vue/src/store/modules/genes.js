import {HTTP} from '@/router/http';

// initial state
const state = {
	current: null,
	genes: [],
	nbGenes: 0,
	variants: [],
	nbVariants: 0,
	phenotypes: [],
	nbPhenotypes: 0,
	associations: [],
	nbGeneVariants: 0,
	geneVariants: [],
	variant: null
}

// getters
const getters = {
	genes: state => state.genes,
	gene: state => state.gene,
	nbGenes: state => state.nbGenes,
	currentGene: state => state.current,
	variants: state => state.variants,
	nbVariants: state => state.nbVariants,
	phenotypes: state => state.phenotypes,
	nbPhenotypes: state => state.phenotypes.length,
	geneVariants: state => state.geneVariants,
	nbGeneVariants: state => state.nbGeneVariants,
	variant: state => state.variant
}

// actions
const actions = {

	getGenes ({ commit } ,params ) {		
		let geneCache = window.localStorage.getItem('genes');
		if (geneCache) geneCache = JSON.parse(geneCache);
		let page = 1;
		if (params !== undefined && params.page) page = +params.page;
		let add = (page > 1);
		if (!state.genes.length){
			HTTP.get('genes/?page='+page).then(res => {
				let genes = res.data.results
				commit('SET_NBGENES',res.data.count);
				if ((params === undefined || params.reset === undefined) && state.genes.length == res.data.count) return;
				if (geneCache && geneCache.length == res.data.count){
					commit('SET_GENES',{genes: geneCache, add:false});
					return;
				}
				commit('SET_GENES',{genes: genes, add: add});
				if (res.data.next && res.data.next.indexOf('?page=') > -1){
					var test = res.data.next.match(/\?page=(\d+)/);
					if (test){
						page = test[1];	
						dispatch('getGenes',{page: page});
					} 
				}
			});
		}
	},
	getVariants ({ commit, dispatch } ,params ) {			
		let variantCache = window.localStorage.getItem('variants');
		if (variantCache) variantCache = JSON.parse(variantCache);

		let page = 1;
		if (params !== undefined && params.page) page = +params.page;
		let add = (page > 1);
		HTTP.get('variants/?page='+page).then(res => {
			let variants = res.data.results;
			commit('SET_NBVARIANTS',res.data.count);
			if ((params === undefined || params.reset === undefined) && state.variants.length == res.data.count) return;
			if (variantCache && variantCache.length == res.data.count){
				commit('SET_VARIANTS',{genes: variantCache, add:false});
				return;
			}

			commit('SET_VARIANTS',{variants: variants, add: add});
			if (res.data.next && res.data.next.indexOf('?page=') > -1){
				var test = res.data.next.match(/\?page=(\d+)/);
				if (test){
					page = test[1];	
					dispatch('getVariants',{page: page});
				} 
				
				
			}
		});
	},
	getPhenotypes ( {commit, dispatch}, params){
		let phenotypeCache = window.localStorage.getItem('phenotypes');
		if (phenotypeCache) phenotypeCache = JSON.parse(phenotypeCache);
		let page = 1;
		if (params !== undefined && params.page) page = +params.page;
		let add = (page > 1);
		HTTP.get('phenotypes/?page='+page).then(res => {
			let phenotypes = res.data.results;
			commit('SET_NBPHENOTYPES',res.data.count);
			if ((params === undefined || params.reset === undefined) && state.phenotypes.length == res.data.count) return;
			if (phenotypeCache && phenotypeCache.length == res.data.count){
				commit('SET_PHENOTYPES',{phenotypes: phenotypeCache, add:false});
				return;
			}
			commit('SET_PHENOTYPES',{phenotypes: phenotypes, add: add});
			if (res.data.next && res.data.next.indexOf('?page=') > -1){
				var test = res.data.next.match(/\?page=(\d+)/);
				if (test){
					page = test[1];	
					dispatch('getPhenotypes',{page: page});
				} 
			}
		});
	},
	getAssociations ( {commit, dispatch}, params){
		let associationCache = window.localStorage.getItem('associations');
		if (associationCache) associationCache = JSON.parse(associationCache);
		let page = 1;
		if (params !== undefined && params.page) page = +params.page;
		let add = (page > 1);
		HTTP.get('associations/?page='+page).then(res => {
			let associations = res.data.results;
			if ((params === undefined || params.reset === undefined) && state.associations.length == res.data.count) return;
			if (associationCache && associationCache.length == res.data.count){
				commit('SET_ASSOCIATIONS',{associations: associationCache, add:false});
				return;
			}
			
			commit('SET_ASSOCIATIONS',{associations: associations, add: add});
			if (res.data.next && res.data.next.indexOf('?page=') > -1){
				var test = res.data.next.match(/\?page=(\d+)/);
				if (test){
					page = test[1];	
					dispatch('getAssociations',{page: page});
				} 
			}
		});
		
	},
	listGeneVariants ( { commit, dispatch }, params){
		let page = 1;
		if (params !== undefined && params.page) page = +params.page;
		let add = (page > 1);
		HTTP.get('variants/?search='+params.gene+"&page="+page).then(res => {
			let geneVariants = res.data.results;
			commit('SET_NB_GENE_VARIANTS',res.data.count);
			if ((params === undefined || params.reset === undefined) && state.geneVariants.length == res.data.count) return;
			commit('SET_GENE_VARIANTS',{geneVariants: geneVariants, add: add});
			if (res.data.next && res.data.next.indexOf('?page=') > -1){
				var test = res.data.next.match(/\?page=(\d+)/);
				if (test){
					page = test[1];	
					dispatch('listGeneVariants',{gene: params.gene,page: page});
				} 

			}

		})
	},
	getGeneVariant ( {commit, dispatch }, params){
		return HTTP.get('variants/'+params.variant).then(res => {
			let variant = res.data;
			commit('SET_VARIANT',variant);
			return variant;
		})
	}
	
	


}

// mutations
const mutations = {
	SET_GENES (state, params) {
		if (params.add){
			state.genes = state.genes.concat(params.genes);
		}
		else {
			state.genes = params.genes	
		}
		window.localStorage.setItem('genes',JSON.stringify(state.genes));
	},
	SET_NBGENES (state,nbGenes){
		state.nbGenes = nbGenes;
	},
	SELECT_GENE (state, gene) {
		state.nbGeneVariants = 0;
		state.geneVariants = [];
		state.current = gene;
	},
	SET_VARIANTS (state, params) {
		if (params.add){
			state.variants = state.variants.concat(params.variants);
		}
		else if (params.variants !== undefined) {
			state.variants = params.variants	
		}
		let json_variants = JSON.stringify(state.variants);
		if (json_variants !== undefined) window.localStorage.setItem('variants',json_variants);		
	},
	SET_NBVARIANTS (state,nbVariants){
		state.nbVariants = nbVariants;
	},
	SET_PHENOTYPES (state, params) {
		if (params.add){
			state.phenotypes = state.phenotypes.concat(params.phenotypes);
		}
		else {
			state.phenotypes = params.phenotypes	
		}
		window.localStorage.setItem('phenotypes',JSON.stringify(state.phenotypes));
	},
	SET_NBPHENOTYPES (state,nbPhenotypes){
		state.nbPhenotypes = nbPhenotypes;
	},
	SET_ASSOCIATIONS (state, params) {
		if (params.add){
			state.associations = state.associations.concat(params.associations);
		}
		else {
			state.associations = params.associations	
		}
		window.localStorage.setItem('associations',JSON.stringify(state.associations));
	},
	SET_NBASSOCIATIONS (state,nbAssociations){
		state.nbAssociations = nbAssociations;
	},
	SET_GENE_VARIANTS (state,params){
		if (params.add){
			state.geneVariants = state.geneVariants.concat(params.geneVariants);
		}
		else {
			state.geneVariants = params.geneVariants	
		}	
	},
	SET_NB_GENE_VARIANTS ( state, nbGeneVariants){
		state.nbGeneVariants = nbGeneVariants;
	},
	SET_VARIANT (state,variant){
		state.variant = variant;
	}
	
}

export default {
	state,
	getters,
	actions,
	mutations
}