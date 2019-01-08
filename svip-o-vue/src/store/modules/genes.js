import {HTTP} from '@/router/http';

// initial state
const state = {
	current: null,
	all: [],
	variants: [],
	alterations: []
}

// getters
const getters = {
	genes: state => state.all,
	currentGene: state => state.current,
	variants: state => state.variants,
	alterations: state => state.alterations
}

// actions
const actions = {

	getGenes ({ commit }) {			
		if (!state.all.length){
			HTTP.get('utils/cancerGeneList').then(res => {
				let data = res.data;
				commit('SET_GENES', data)
				return data;
			});			
		}
	},
	getVariants ( {commit }){
		if (!state.variants.length){
			HTTP.get('utils/allAnnotatedVariants').then(res => {
				let data = res.data;
				commit('SET_VARIANTS',data);
				return data;
			});
		}
	},
	getAlterations ( {commit}, params){
		console.log(params);
		if (params.gene_id){
			commit('SELECT_GENE',params.gene_id);
		}
		HTTP.get('evidences/lookup?entrezGeneId='+params.gene_id+"&source=oncotree").then(res => {
			commit('SET_ALTERATIONS',res.data);
			return res.data;
		})
	}


}

// mutations
const mutations = {
	SET_GENES (state, genes) {
		state.all = genes
	},
	SELECT_GENE (state, gene_id){
		let gene = state.all.filter(g => {return g.entrezGeneId == gene_id;});
		if (gene.length) gene = gene[0];
		else gene = null;
		state.current = gene;
	},
	SET_VARIANTS (state,variants){
		state.variants = variants;
	},
	SET_ALTERATIONS(state,alterations){
		state.alterations = alterations;
	}
}

export default {
	state,
	getters,
	actions,
	mutations
}