import { HTTP, HTTProot } from "@/router/http";
import ulog from 'ulog';

const log = ulog('Store:users');

// FIXME: we currently store the JWT access/refresh tokens in localstorage, but this might make us vulnerable to
//  an XSS attack through our dependencies...i mean, i don't really know if any of this is "secure" if we can't
//  trust our own code, but maybe we could use httponly cookies or something once django-rest-framework-simplejwt
//  supports them.
//  anyway, the following bits control whether access/refresh tokens are persisted to localstorage or not.
const JWT_IN_LOCALSTORAGE = true;
const JWT_REFRESH_IN_LOCALSTORAGE = true;

// indicates that we're using httponly cookies to perform authentication
// if our token is "missing", we should perform a request anyway to see if we actually are authenticated
// (note that this feature requires server-side support that hasn't been deployed to svip-dev yet)
export const USING_JWT_COOKIE = false;

// initial state
const state = {
    currentJWT: JWT_IN_LOCALSTORAGE ? localStorage.getItem("user-jwt") : null,
    currentRefreshJWT: JWT_REFRESH_IN_LOCALSTORAGE ? localStorage.getItem("user-jwt-refresh") : null,
    dataViaCookie: null
};

// enums
export const TokenErrors = {
    NONE_FOUND: 0,
    EXPIRED: 1,
    NO_REFRESH_TOKEN: 2,
    REFRESH_EXPIRED: 3
};

// getters
const getters = {
    jwt: (state) => state.currentJWT,
    jwtRefresh: (state) => state.currentRefreshJWT,

    jwtData: (state, getters) => {
        return USING_JWT_COOKIE ? state.dataViaCookie : (
            state.currentJWT ? JSON.parse(atob(getters.jwt.split('.')[1])) : null
        );
    },
    jwtExp: (state, getters) => getters.jwtData ? getters.jwtData.exp : null,
    jwtSubject: (state, getters) => getters.jwtData ? getters.jwtData.sub : null,
    jwtIssuer: (state, getters) => getters.jwtData ? getters.jwtData.iss : null,

    username: (state, getters) => getters.jwtData ? getters.jwtData.username : null,
    userID: (state, getters) => getters.jwtData ? getters.jwtData.user_id : null,
    groups: (state, getters) => getters.jwtData ? getters.jwtData.groups : null,

    currentUser: (state, getters) => {
        if (!getters.jwtData) {
            return null;
        }

        return {
            username: getters.username,
            user_id: getters.userID,
            groups: getters.groups
        };
    }
};

// actions
const actions = {
    login({commit}, {username, password}) {

        return HTTProot.post(`token/`, {username, password}).then(response => {
            const {access, refresh} = response.data;

            // TODO: extract and decode the JWT from the response, populate structure below
            commit("LOGIN", {access, refresh});

            return true;
        });
    },

    async checkCredentials({commit, getters, dispatch}) {
        if (USING_JWT_COOKIE) {
            return await HTTProot.get('token/info/').then((response) => {
                log.trace("JWT got: ", response);
                commit("LOGIN_VIA_COOKIE", response.data);
                return {valid: true};
            }).catch((err) => {
                // FIXME: depending on the error we should return different statuses, but this is fine for now
                log.warn("Cookie-based auth failed: ", err);
                // we should also clear any stale auth data, since we're not authed
                commit("LOGOUT");
                return {valid: false, reason: TokenErrors.NONE_FOUND};
            });
        } else {
            // we need a jwt if it's being stored
            const jwt = getters.jwt;
            const jwtRefresh = getters.jwtRefresh;

            if (!jwt) {
                return {valid: false, reason: TokenErrors.NONE_FOUND};
            }

            // now verify that it's not expired
            // log.trace("expiration: ", getters.jwtExp);
            if (getters.jwtExp && Math.floor(Date.now() / 1000) >= getters.jwtExp) {
                // if it's expired, we should first attempt to refresh it with the current token
                return dispatch("refresh")
                    .then((response) => {
                        return response;
                    }).catch(() => {
                        // oops, we failed to do that, too
                        return {valid: false, reason: TokenErrors.EXPIRED};
                    });
            }

            // if we're here, it means everything is good, so process the login and annotate our requests with the token
            commit("LOGIN", {access: jwt, refresh: jwtRefresh});
            return {valid: true};
        }
    },

    checkPermissions() { // params: ({commit}, {permissions, condition = 'all'})
        return new Promise((resolve) => {
            // FIXME: think of a meaningful way to verify this in the client
            resolve(true);
        });
    },

    refresh({commit, getters}) {
        const jwtRefresh = getters.jwtRefresh;

        // ...but if we can't even do that, we can't proceed
        if (!jwtRefresh) {
            return {valid: false, reason: TokenErrors.NO_REFRESH_TOKEN};
        }

        log.trace("Attempting refresh with token: ", jwtRefresh);

        return HTTProot.post(`token/refresh/`, {refresh: jwtRefresh}).then(response => {

            // vm.$snotify.info(`Refreshed access token`);
            log.trace("Refreshed access token");

            // replace the existing token with the new one if we succeed
            const {access} = response.data;

            // TODO: extract and decode the JWT from the response, populate structure below
            commit("LOGIN", {access});

            return {valid: true};
        }).catch((err) => {
            log.warn(err);
            return {valid: false, reason: TokenErrors.REFRESH_EXPIRED}
        });
    },

    async logout({commit}) {
        log.trace("Beginning log out...");

        // we need to tell the server that we're going away so it can clear our cookie for us
        await HTTProot.post('token/invalidate/');

        log.trace("...done");

        delete HTTP.defaults.headers.common["Authorization"];
        commit("LOGOUT");
        return {status: 'done'};
    }
};

// mutations
const mutations = {
    LOGIN(state, payload) {
        const {access, refresh} = payload;
        state.currentJWT = access;
        if (JWT_IN_LOCALSTORAGE) {
            localStorage.setItem("user-jwt", access);
        }

        if (refresh) {
            state.currentRefreshJWT = refresh;

            if (JWT_REFRESH_IN_LOCALSTORAGE) {
                localStorage.setItem("user-jwt-refresh", refresh);
            }
        }
    },

    LOGIN_VIA_COOKIE(state, payload) {
        state.dataViaCookie = payload;
    },

    LOGOUT(state) {
        if (USING_JWT_COOKIE) {
            state.dataViaCookie = null;
        }

        state.currentJWT = null;
        if (JWT_IN_LOCALSTORAGE) {
            localStorage.removeItem("user-jwt");
        }

        state.currentRefreshJWT = null;
        if (JWT_REFRESH_IN_LOCALSTORAGE) {
            localStorage.removeItem("user-jwt-refresh");
        }
    }
};

export default {
    state,
    getters,
    actions,
    mutations
};
