import svipVariants from "@/assets/svip_variants.json";
import {HTTP} from "@/router/http";

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
	variant: null,
	svipVariants: svipVariants,
	svipVariant: null,
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

			commit("SET_NBGENES", stats.genes);
			commit("SET_NBVARIANTS", stats.variants);
			commit("SET_NBPHENOTYPES", stats.phenotypes);
		});
	},

	async getGeneVariants({commit, dispatch}, params) {
		await HTTP.get(`genes/${params.gene_id}`).then(res => {
			commit("SELECT_GENE", res.data);
		});
		await HTTP.get(`genes/${params.gene_id}/variants?page_size=9999`).then(res => {
			// FIXME: properly support paging at a later date
			commit("SET_VARIANTS", { variants: res.data.results });
		});
	},

	getGeneVariant({commit, dispatch}, params) {
		return HTTP.get("variants/" + params.variant_id).then(res => {
			let gene = res.data.gene;
			let variant = res.data;
			commit("SELECT_GENE", gene);

			commit("SET_VARIANT", variant);

			// look up the corresponding SVIP variant data, too, if available
			dispatch('selectSvipDataForVariant');
		});
	},

	selectVariant({commit, dispatch}, params) {
		let variant = state.variants.find(v => v.id === params.variant_id);

		// find the corresponding mock data for this variant, too, so we can display mock-specific stuff
		const svip_v = state.svipVariants.find(
			x =>
				x.gene_name === variant.gene_symbol &&
				x.variant_name === variant.name
		);

		commit("SET_VARIANT", variant);
		commit("SELECT_SVIP_VARIANT", svip_v);
	},

	selectSvipDataForVariant({commit, dispatch}) {
		let variant = state.variant;

		// find the corresponding mock data for this variant, too, so we can display mock-specific stuff
		const svip_v = state.svipVariants.find(
			x =>
				x.gene_name === variant.gene_symbol &&
				x.variant_name === variant.name
		);

		commit("SELECT_SVIP_VARIANT", svip_v);
	},

	toggleShowSVIP({commit, dispatch}, params) {
		commit("SET_SHOW_ONLY_SVIP", params.showOnlySVIP);
	}
};

// mutations
const mutations = {
	SET_GENES(state, params) {
		if (params.add) {
			state.genes = state.genes.concat(params.genes);
		} else {
			state.genes = params.genes;
		}
	},
	SET_NBGENES(state, nbGenes) {
		state.nbGenes = nbGenes;
	},
	SELECT_GENE(state, gene) {
		state.nbGeneVariants = 0;
		state.geneVariants = [];
		state.currentGene = gene;
	},
	SET_VARIANTS(state, params) {
		if (params.add) {
			state.variants = state.variants.concat(params.variants);
		} else if (params.variants !== undefined) {
			state.variants = params.variants;
		}
	},
	SET_NBVARIANTS(state, nbVariants) {
		state.nbVariants = nbVariants;
	},
	SET_PHENOTYPES(state, params) {
		if (params.add) {
			state.phenotypes = state.phenotypes.concat(params.phenotypes);
		} else {
			state.phenotypes = params.phenotypes;
		}
		window.localStorage.setItem(
			"phenotypes",
			JSON.stringify(state.phenotypes)
		);
	},
	SET_NBPHENOTYPES(state, nbPhenotypes) {
		state.nbPhenotypes = nbPhenotypes;
	},
	SET_ASSOCIATIONS(state, params) {
		if (params.add) {
			state.associations = state.associations.concat(params.associations);
		} else {
			state.associations = params.associations;
		}
		window.localStorage.setItem(
			"associations",
			JSON.stringify(state.associations)
		);
	},
	SET_GENE_VARIANTS(state, params) {
		if (params.add) {
			state.geneVariants = state.geneVariants.concat(params.geneVariants);
		} else {
			state.geneVariants = params.geneVariants;
		}
	},
	SET_NB_GENE_VARIANTS(state, nbGeneVariants) {
		state.nbGeneVariants = nbGeneVariants;
	},
	SET_VARIANT(state, variant) {
		state.variant = variant;
	},
	SELECT_SVIP_VARIANT(state, variant) {
		state.svipVariant = variant;
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
