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
	pubmedInfo: JSON.parse(localStorage.getItem('pubmedInfo')) || {}
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
	getPubmedInfo({commit, dispatch}, {pmid}) {
		return new Promise((resolve, reject) => {
			if (state.pubmedInfo.hasOwnProperty(pmid)) {
				// return the existing thing
				resolve(state.pubmedInfo[pmid])
			}
			else {
				// fire off a request and populate the store, eventually resolving with the thing we got
				// maybe add on extra params, &tool=my_tool&email=my_email@example.com
				const targetURL = `https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=${pmid}&retmode=json&tool=svipdb`;
				return fetch(targetURL)
					.then(res => res.json())
					.then(res => {
						console.log("request: " + targetURL + ", response: ", res);
						commit('SET_PUBMED_INFO', { pmid, data: res.result[pmid] })
						return res.result;
					})
			}
		})
	},

	getBatchPubmedInfo({commit, dispatch}, {pmid_set}) {
		return new Promise((resolve, reject) => {
			console.log("Getting batch PMIDs: ", pmid_set);

			// just get the things we don't have
			const remaining = pmid_set.filter(pmid => !state.pubmedInfo.hasOwnProperty(pmid));

			if (remaining.length > 0) {
				// fire off a request and populate the store, eventually resolving with the thing we got
				// maybe add on extra params, &tool=my_tool&email=my_email@example.com
				const targetURL = `https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=${remaining.join(',')}&retmode=json&tool=svipdb`;
				return fetch(targetURL)
					.then(res => res.json())
					.then(res => {
						console.log("request: " + targetURL + ", response: ", res);

						let retrieved = 0;
						Object.entries(res.result).forEach(([pmid, data]) => {
							commit('SET_PUBMED_INFO', { pmid, data });
							retrieved += 1;
						})
						return retrieved;
					})
			}
			else {
				// we can resolve immediately if there's nothing for us to do
				resolve(-1);
			}
		})
	},
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
	},

	SET_PUBMED_INFO(state, { pmid, data }) {
		state.pubmedInfo[pmid] = data;
		localStorage.setItem('pubmedInfo', JSON.stringify(state.pubmedInfo));
	}
};

export default {
	state,
	getters,
	actions,
	mutations
};
