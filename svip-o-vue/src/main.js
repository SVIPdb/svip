import Vue from "vue";
import App from "./App";
import router from "./router";
import "bootstrap/dist/css/bootstrap.css";
import 'bootstrap-vue/dist/bootstrap-vue.css';
import "@/css/bootstrap.css";
import "@/css/main.css";
import "vue-simple-context-menu/dist/vue-simple-context-menu.css";
import Snotify, {SnotifyPosition} from "vue-snotify";
import "vue-snotify/styles/material.css";
import Access from "@/directives/access";

// imports all the bootstrap parts
import BootstrapVue from 'bootstrap-vue'
Vue.use(BootstrapVue);

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
import "vue-awesome/icons/exclamation-triangle";
import "vue-awesome/icons/chevron-up";
import "vue-awesome/icons/chevron-right";
import "vue-awesome/icons/chevron-down";
import "vue-awesome/icons/tools";
import "vue-awesome/icons/eye";
import "vue-awesome/icons/check";
import "vue-awesome/icons/times";
import "vue-awesome/icons/plus";
import "vue-awesome/icons/plus-square";
import "vue-awesome/icons/minus";
import "vue-awesome/icons/newspaper";
import "vue-awesome/icons/key";
import "vue-awesome/icons/calendar";
import "vue-awesome/icons/user";
import "vue-awesome/icons/trash";
import "vue-awesome/icons/tasks";
import "vue-awesome/icons/pen-alt";
import "vue-awesome/icons/history";

import Icon from "vue-awesome/components/Icon";

import vSelect from "vue-select";
import 'vue-select/dist/vue-select.css';
import VueSimpleContextMenu from 'vue-simple-context-menu'
import VueClipboard from 'vue-clipboard2'
import { ValidationProvider } from 'vee-validate';
import Expander from "@/components/widgets/Expander";

import store from "./store";


Vue.config.productionTip = false;

Vue.use(Snotify, {toast: {position: SnotifyPosition.centerTop, showProgressBar: false}});
Vue.use(VueClipboard);

// register vee-validate's validator
Vue.component('ValidationProvider', ValidationProvider);

// Vue.use(Vuex) // commented out b/c it's included in ./store.js
Vue.component("icon", Icon);
Vue.directive("access", Access);
Vue.component("v-select", vSelect);
Vue.component('vue-simple-context-menu', VueSimpleContextMenu);

// the little arrow to the left of rows that allows them to be expanded, used everywhere
Vue.component("expander", Expander);

export default new Vue({
    el: "#app",
    router,
    store,
    components: {App},
    template: "<App/>"
});
