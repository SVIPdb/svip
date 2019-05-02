import {HTTP} from "@/router/http";
import {serverURL} from "@/app_config";

// initial state
const state = {
	currentJWT: null
};

// getters
const getters = {
	jwt: (state) => state.currentJWT,
	jwtData: (state, getters) => state.currentJWT ? JSON.parse(atob(getters.jwt.split('.')[1])) : null,
	jwtSubject: (state, getters) => getters.jwtData ? getters.jwtData.sub : null,
	jwtIssuer: (state, getters) => getters.jwtData ? getters.jwtData.iss : null,
	username: (state, getters) => getters.jwtData ? getters.jwtData.username : null,
	groups: (state, getters) => getters.jwtData ? getters.jwtData.groups : null,
	currentUser: (state, getters) => {
		if (!getters.jwtData) {
			return null;
		}

		return {
			username: getters.username,
			groups: getters.groups
		};
	}
};

// actions
const actions = {
	login({commit}, { username, password }) {

		return HTTP.post(`token/`, { username, password }, {
			baseURL: serverURL.replace("/v1", "")
		}).then(response => {
			const { access, refresh } = response.data;

			// TODO: extract and decode the JWT from the response, populate structure below
			commit("LOGIN", access);

			localStorage.setItem("user-jwt", state.currentJWT);
			HTTP.defaults.headers.common["Authorization"] = "Bearer " + state.currentJWT;

			return true;
		});
	},

	checkCredentials({commit}) {
		if (state.currentJWT) {
			return true;
		}
		else {
			// attempt to fetch our JWT from localstorage, since it's not in memory
			const jwt = localStorage.getItem("user-jwt");

			if (!jwt) {
				return false;
			}

			commit("LOGIN", jwt);
			HTTP.defaults.headers.common["Authorization"] = "Bearer " + jwt;
			return true;
		}
	},

	checkPermissions({commit}, { permissions, condition='all' }) {
		return new Promise((resolve) => {
			// FIXME: think of a meaningful way to verify this in the client
			resolve(true);
		});
	},

	logout({commit}) {
		localStorage.removeItem("user-jwt");
		delete HTTP.defaults.headers.common["Authorization"];
		commit("LOGOUT");
	}
};

// mutations
const mutations = {
	LOGIN(state, jwt) {
		state.currentJWT = jwt;
	},
	LOGOUT(state) {
		state.currentJWT = null;
	}
};

export default {
	state,
	getters,
	actions,
	mutations
};

