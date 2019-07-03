import Vue from "vue";
import App from "./App";
import router from "./router";
import BootstrapVue from "bootstrap-vue";
import "bootstrap/dist/css/bootstrap.css";
import 'bootstrap-vue/dist/bootstrap-vue.css';
import "@/css/bootstrap.css";
import "@/css/main.css";
import Snotify, {SnotifyPosition} from "vue-snotify";
import "vue-snotify/styles/material.css";
import Access from "@/directives/access";

// we import only the icons we actually use in the project to dramatically reduce bundle size
import "vue-awesome/icons/sign-out-alt";
import "vue-awesome/icons/sign-in-alt";
import "vue-awesome/icons/sort";
import "vue-awesome/icons/sort-up";
import "vue-awesome/icons/sort-down";
import "vue-awesome/icons/star";
import "vue-awesome/icons/regular/star";
import "vue-awesome/icons/spinner";
import "vue-awesome/icons/external-link-alt";

import Icon from "vue-awesome/components/Icon";

import vSelect from "vue-select";

import store from "./store";

Vue.config.productionTip = false;

Vue.use(Snotify, { toast: { position: SnotifyPosition.centerTop, showProgressBar: false } });
Vue.use(BootstrapVue);
// Vue.use(Vuex) // commented out b/c it's included in ./store.js
Vue.component("icon", Icon);
Vue.directive("access", Access);
Vue.component("v-select", vSelect);

export default new Vue({
	el: "#app",
	router,
	store,
	components: {App},
	template: "<App/>"
});
