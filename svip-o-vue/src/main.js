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

import "vue-awesome/icons"; // FIXME: import only what we use to reduce the bundle size
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
