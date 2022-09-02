import Vue from "vue";
import Vuex from "vuex";
import users from "./modules/users";
import genes from "./modules/genes";
import site from "./modules/site";
import curation from "./modules/curation";

Vue.use(Vuex);

export default new Vuex.Store({
    modules: {
        users,
        genes,
        site,
        curation
    },
});
