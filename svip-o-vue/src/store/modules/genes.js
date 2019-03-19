import {HTTP} from "@/router/http";

// initial state
const state = {
	current: null,

	currentGene: null,
	currentVariant: null,

	genes: [],
	nbGenes: 0,
	variants: [],
	nbVariants: 0,
	phenotypes: [],
	nbPhenotypes: 0,
	associations: [],
	nbGeneVariants: 0,
	geneVariants: [],
	variant: null,
	showOnlySVIP: localStorage.getItem('showOnlySVIP') === 'true'
};

// getters
const getters = {
	genes: state => state.genes,
	gene: state => state.gene,
	nbGenes: state => state.nbGenes,
	currentGene: state => state.currentGene,
	variants: state => state.variants,
	nbVariants: state => state.nbVariants,
	phenotypes: state => state.phenotypes,
	nbPhenotypes: state => state.phenotypes.length,
	geneVariants: state => state.geneVariants,
	nbGeneVariants: state => state.nbGeneVariants,
	variant: state => state.variant,
	svipVariants: state => state.svipVariants,
	svipVariant: state => state.svipVariant
};

// actions
const actions = {
	getSiteStats({commit}, params) {
		return HTTP.get("query/stats").then(res => {
			const stats = res.data;

			commit('SET_SITE_STATS', {
				nbGenes: stats.genes,
				nbVariants: stats.variants,
				nbPhenotypes: stats.phenotypes
			});
		});
	},

	getGene({commit, dispatch}, params) {
		return HTTP.get(`genes/${params.gene_id}`).then(res => {
			commit("SELECT_GENE", res.data);
		});
	},

	getGeneVariant({commit, dispatch}, params) {
		return HTTP.get("variants/" + params.variant_id).then(res => {
			let gene = res.data.gene;
			let variant = res.data;
			commit("SELECT_GENE", gene);
			commit("SET_VARIANT", variant);
		});
	},

	selectVariant({commit, dispatch}, params) {
		let variant = state.variants.find(v => v.id === params.variant_id);
		commit("SET_VARIANT", variant);
	},

	toggleShowSVIP({commit, dispatch}, params) {
		commit("SET_SHOW_ONLY_SVIP", params.showOnlySVIP);
	}
};

// mutations
const mutations = {
	SET_SITE_STATS(state, { nbGenes, nbVariants, nbPhenotypes }) {
		state.nbGenes = nbGenes;
		state.nbVariants = nbVariants;
		state.nbPhenotypes = nbPhenotypes;
	},

	SET_GENES(state, params) {
		if (params.add) {
			state.genes = state.genes.concat(params.genes);
		} else {
			state.genes = params.genes;
		}
	},
	SET_VARIANTS(state, params) {
		if (params.add) {
			state.variants = state.variants.concat(params.variants);
		} else if (params.variants !== undefined) {
			state.variants = params.variants;
		}
	},

	SELECT_GENE(state, gene) {
		state.nbGeneVariants = 0;
		state.geneVariants = [];
		state.currentGene = gene;
	},
	SET_VARIANT(state, variant) {
		state.variant = variant;
	},

	SET_SHOW_ONLY_SVIP(state, v) {
		state.showOnlySVIP = v;
		localStorage.setItem('showOnlySVIP', v ? 'true' : 'false');
	}
};

export default {
	state,
	getters,
	actions,
	mutations
};
