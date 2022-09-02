import {HTTP} from '@/router/http';
import {parseVariantsForReview} from './helpers';

const state = {
	variantsForReview: [],
};

const getters = {
	variantsForReview: state => state.variantsForReview,
};

const actions = {
	getVariantsForReview({commit}, review_table = false) {
		let URL = 'variants/review_process';
		return HTTP.get(URL)
			.then(res => {
				commit('SET_VARIANTS_FOR_REVIEW', parseVariantsForReview(res.data.results));
			})
			.catch(err => {
				console.log(err);
			});
	},
};

const mutations = {
	SET_VARIANTS_FOR_REVIEW(state, params) {
		state.variantsForReview = params;
	},
};

export default {
	state,
	getters,
	actions,
	mutations,
};
