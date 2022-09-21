import Vue from 'vue';

export const state = Vue.observable({
    isNavOpen: false,
});

export const mutations = {
    SET_NAV(state, {navState}) {
        state.isNavOpen = navState;
    },
    TOGGLE_NAV(state) {
        state.isNavOpen = !state.isNavOpen;
    },
};

export default {
    state,
    mutations,
};
