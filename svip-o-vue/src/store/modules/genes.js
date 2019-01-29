import svipVariants from '@/assets/svip_variants.json'
import {HTTP} from '@/router/http'

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
    showOnlySVIP: false
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
    variant: state => state.variant,
    svipVariants: state => state.svipVariants,
    svipVariant: state => state.svipVariant
}

// actions
const actions = {
    getSiteStats({commit}, params) {
        HTTP.get('query/stats').then(res => {
            const stats = res.data;

            commit('SET_NBGENES', stats.genes);
            commit('SET_NBVARIANTS', stats.variants);
            commit('SET_NBPHENOTYPES', stats.phenotypes);
        })
    },

    getGenes({commit}, params) {
        let geneCache = window.localStorage.getItem('genes')
        if (geneCache) geneCache = JSON.parse(geneCache)
        let page = 1
        if (params !== undefined && params.page) page = +params.page
        let add = (page > 1)
        if (!state.genes.length) {
            HTTP.get('genes/?page=' + page).then(res => {
                let genes = res.data.results
                if ((params === undefined || params.reset === undefined) && state.genes.length === res.data.count) return
                if (geneCache && geneCache.length === res.data.count) {
                    commit('SET_GENES', {genes: geneCache, add: false})
                    return
                }
                commit('SET_GENES', {genes: genes, add: add})
                if (res.data.next && res.data.next.indexOf('?page=') > -1) {
                    const test = res.data.next.match(/\?page=(\d+)/);
                    if (test) {
                        page = test[1]
                        dispatch('getGenes', {page: page})
                    }
                }
            })
        }
    },

    getVariants({commit, dispatch}, params) {
        let variantCache = window.localStorage.getItem('variants')
        if (variantCache) variantCache = JSON.parse(variantCache)

        let page = 1
        if (params !== undefined && params.page) page = +params.page
        let add = (page > 1)
        HTTP.get('variants/?page=' + page).then(res => {
            let variants = res.data.results
            if ((params === undefined || params.reset === undefined) && state.variants.length === res.data.count) return
            if (variantCache && variantCache.length === res.data.count) {
                commit('SET_VARIANTS', {variants: variantCache, add: false})
                return
            }

            commit('SET_VARIANTS', {variants: variants, add: add})
            if (res.data.next && res.data.next.indexOf('?page=') > -1) {
                const test = res.data.next.match(/\?page=(\d+)/);
                if (test) {
                    page = test[1]
                    dispatch('getVariants', {page: page})
                }
            }
        })
    },

    getPhenotypes({commit, dispatch}, params) {
        let phenotypeCache = window.localStorage.getItem('phenotypes')
        if (phenotypeCache) phenotypeCache = JSON.parse(phenotypeCache)
        let page = 1
        if (params !== undefined && params.page) page = +params.page
        let add = (page > 1)
        HTTP.get('phenotypes/?page=' + page).then(res => {
            let phenotypes = res.data.results
            if ((params === undefined || params.reset === undefined) && state.phenotypes.length === res.data.count) return
            if (phenotypeCache && phenotypeCache.length === res.data.count) {
                commit('SET_PHENOTYPES', {phenotypes: phenotypeCache, add: false})
                return
            }
            commit('SET_PHENOTYPES', {phenotypes: phenotypes, add: add})
            if (res.data.next && res.data.next.indexOf('?page=') > -1) {
                const test = res.data.next.match(/\?page=(\d+)/);
                if (test) {
                    page = test[1]
                    dispatch('getPhenotypes', {page: page})
                }
            }
        })
    },

    getAssociations({commit, dispatch}, params) {
        let associationCache = window.localStorage.getItem('associations')
        if (associationCache) associationCache = JSON.parse(associationCache)
        let page = 1
        if (params !== undefined && params.page) page = +params.page
        let add = (page > 1)
        HTTP.get('associations/?page=' + page).then(res => {
            let associations = res.data.results
            if ((params === undefined || params.reset === undefined) && state.associations.length === res.data.count) return
            if (associationCache && associationCache.length === res.data.count) {
                commit('SET_ASSOCIATIONS', {associations: associationCache, add: false})
                return
            }

            commit('SET_ASSOCIATIONS', {associations: associations, add: add})
            if (res.data.next && res.data.next.indexOf('?page=') > -1) {
                const test = res.data.next.match(/\?page=(\d+)/);
                if (test) {
                    page = test[1]
                    dispatch('getAssociations', {page: page})
                }
            }
        })
    },

    listGeneVariants({commit, dispatch}, params) {
        let page = 1
        if (params !== undefined && params.page) page = +params.page
        let add = (page > 1)
        HTTP.get('variants/?search=' + params.gene + '&page=' + page).then(res => {
            let geneVariants = res.data.results
            commit('SET_NB_GENE_VARIANTS', res.data.count)
            if ((params === undefined || params.reset === undefined) && state.geneVariants.length === res.data.count) return
            commit('SET_GENE_VARIANTS', {geneVariants: geneVariants, add: add})
            if (res.data.next && res.data.next.indexOf('?page=') > -1) {
                const test = res.data.next.match(/\?page=(\d+)/);
                if (test) {
                    page = test[1]
                    dispatch('listGeneVariants', {gene: params.gene, page: page})
                }
            }
        })
    },

    getGeneVariant({commit, dispatch}, params) {
        return HTTP.get('variants/' + params.variant).then(res => {
            let variant = res.data
            commit('SET_VARIANT', variant)
            return variant
        })
    },

    selectVariant({commit, dispatch}, params) {
        let variant = _.filter(state.variants, v => {
            return v.id === params.variant_id
        })[0]

        // find the corresponding mock data for this variant, too, so we can display mock-specific stuff
        const svip_v = state.svipVariants.find(
            (x) => x.gene_name === variant.gene_symbol && x.variant_name === variant.name
        );

        commit('SET_VARIANT', variant)
        commit('SELECT_SVIP_VARIANT', svip_v)
    },

    selectSvipVariant({commit, dispatch}, params) {
        const variant = (params.variant_id)
            ? _.filter(state.variants, v => v.id === (params.variant_id | 0))[0]
            : params.variant;

        // find the corresponding mock data for this variant
        const svip_v = state.svipVariants.find(
            (x) => x.gene_name === variant.gene_symbol && x.variant_name === variant.name
        );

        commit('SELECT_SVIP_VARIANT', svip_v)
    },

    toggleShowSVIP({commit, dispatch}, params) {
        commit('SET_SHOW_ONLY_SVIP', params.showOnlySVIP);
    }
}

// mutations
const mutations = {
    SET_GENES(state, params) {
        if (params.add) {
            state.genes = state.genes.concat(params.genes)
        } else {
            state.genes = params.genes
        }
        window.localStorage.setItem('genes', JSON.stringify(state.genes))
    },
    SET_NBGENES(state, nbGenes) {
        state.nbGenes = nbGenes
    },
    SELECT_GENE(state, gene) {
        state.nbGeneVariants = 0
        state.geneVariants = []
        state.current = gene
    },
    SET_VARIANTS(state, params) {
        if (params.add) {
            state.variants = state.variants.concat(params.variants)
        } else if (params.variants !== undefined) {
            state.variants = params.variants
        }
        let json_variants = JSON.stringify(state.variants)
        if (json_variants !== undefined) window.localStorage.setItem('variants', json_variants)
    },
    SET_NBVARIANTS(state, nbVariants) {
        state.nbVariants = nbVariants
    },
    SET_PHENOTYPES(state, params) {
        if (params.add) {
            state.phenotypes = state.phenotypes.concat(params.phenotypes)
        } else {
            state.phenotypes = params.phenotypes
        }
        window.localStorage.setItem('phenotypes', JSON.stringify(state.phenotypes))
    },
    SET_NBPHENOTYPES(state, nbPhenotypes) {
        state.nbPhenotypes = nbPhenotypes
    },
    SET_ASSOCIATIONS(state, params) {
        if (params.add) {
            state.associations = state.associations.concat(params.associations)
        } else {
            state.associations = params.associations
        }
        window.localStorage.setItem('associations', JSON.stringify(state.associations))
    },
    SET_NBASSOCIATIONS(state, nbAssociations) {
        state.nbAssociations = nbAssociations
    },
    SET_GENE_VARIANTS(state, params) {
        if (params.add) {
            state.geneVariants = state.geneVariants.concat(params.geneVariants)
        } else {
            state.geneVariants = params.geneVariants
        }
    },
    SET_NB_GENE_VARIANTS(state, nbGeneVariants) {
        state.nbGeneVariants = nbGeneVariants
    },
    SET_VARIANT(state, variant) {
        state.variant = variant
    },
    SELECT_SVIP_VARIANT(state, variant) {
        state.svipVariant = variant
    },

    SET_SHOW_ONLY_SVIP(state, v) {
        state.showOnlySVIP = v;
    }
}

export default {
    state,
    getters,
    actions,
    mutations
}
