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
import "vue-awesome/icons";
import lodash from "lodash";
import Icon from "vue-awesome/components/Icon";
import VeeValidate from "vee-validate";
import vSelect from "vue-select";

import store from "./store";

Vue.config.productionTip = false;

Vue.use(Snotify, { toast: { position: SnotifyPosition.rightTop } });
Vue.use(BootstrapVue);
Vue.use(VeeValidate, {fieldsBagName: "formFields"});
Vue.use(lodash);
// Vue.use(Vuex) // commented out b/c it's included in ./store.js
Vue.component("icon", Icon);
Vue.directive("access", Access);
Vue.component("v-select", vSelect);
// globally (in your main .js file)

new Vue({
	el: "#app",
	router,
	store,
	components: {App},
	template: "<App/>"
});
