/* eslint-disable no-console */
import '@babel/polyfill'
import 'mutationobserver-shim'
import Vue from "vue";
import '@/plugins/bootstrap-vue'
import App from "./App";
import router from "./router";
import "@/css/bootstrap.css";
import "@/css/main.css";
import "vue-simple-context-menu/dist/vue-simple-context-menu.css";
import Snotify, {
    SnotifyPosition
} from "vue-snotify";
import "vue-snotify/styles/material.css";
import Access from "@/directives/access";
import '@/plugins/vue-awesome'
import AsyncComputed from 'vue-async-computed'

import '@/css/nprogress-custom.css';

import vSelect from "vue-select";
import 'vue-select/dist/vue-select.css';
import VueSimpleContextMenu from 'vue-simple-context-menu'
import VueClipboard from 'vue-clipboard2'
import {
    ValidationProvider
} from 'vee-validate';
import RowExpander from "@/components/widgets/RowExpander";
import Expander from "@/components/widgets/Expander";

import VueConfirmDialog from 'vue-confirm-dialog'

import store from "./store";
import i18n from '@/i18n'

// enables the asyncComputed key, allowing computed properties to return promises
Vue.use(AsyncComputed);

Vue.use(VueConfirmDialog)

Vue.config.productionTip = false;

Vue.use(Snotify, {
    toast: {
        position: SnotifyPosition.centerTop,
        showProgressBar: false
    }
});
Vue.use(VueClipboard);

Vue.component('vue-confirm-dialog', VueConfirmDialog.default)

// register vee-validate's validator
Vue.component('ValidationProvider', ValidationProvider);

// Vue.use(Vuex) // commented out b/c it's included in ./store.js
Vue.directive("access", Access);
Vue.component("v-select", vSelect);
Vue.component('vue-simple-context-menu', VueSimpleContextMenu);

// a utility component that binds variables to its slots
Vue.component("pass", {
    render() {
        return this.$scopedSlots.default(this.$attrs);
    }
});

// the little arrow to the left of rows that allows them to be expanded, used everywhere
Vue.component("row-expander", RowExpander);
Vue.component("expander", Expander);

// ignores the pmca-element defined  in src/support/pmca/pmca-element.js, which is used in the VariomesFullText component
// refer to https://v3.vuejs.org/guide/migration/custom-elements-interop.html#overview for changes we'll need to make
// when we move to vue v3
Vue.config.ignoredElements = ['pmca-element'];

export default new Vue({
    el: "#app",
    router,
    store,
    i18n,
    components: {
        App
    },
    template: "<App/>"
});

window.addEventListener('message', e => {
    if (process.env.NODE_ENV !== 'production' && e.data && e.data.type === 'webpackInvalid') {
        console.clear();
        console.log("*** cleared due to hot-module reload ***");
    }
});
