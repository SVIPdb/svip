/* eslint-disable */
<template>
    <div id="app">
        <vue-snotify></vue-snotify>
        <nav-header></nav-header>

        <!-- content -->
        <router-view style="margin: 90px auto 200px auto"/>

        <nav-footer></nav-footer>
    </div>
</template>

<script>
import Vue from 'vue'
import navHeader from '@/components/navheader'
import navFooter from '@/components/navfooter'

/* used in ViewVariant, and potentially also in ViewGene */
Vue.component('optional', {
    props: ['val'],
    template: `
    <td :class="{unavailable: !val}">
        <span v-if="val"><slot></slot></span>
        <span v-else>unavailable</span>
    </td>`
});

Vue.component('coordinates', {
    props: ['val'],
    template: `
    <optional :val="val">
        <span v-if="val"><span class="text-muted">{{val.transcript}}:</span>{{val.change}}</span>
    </optional>`
});

export default {
    components: {navHeader, navFooter},
    name: 'App',
    computed: {
        year() {
            return new Date().getFullYear()
        }
    }
}
</script>

<style>

.pointer {
    cursor: pointer;
}

.ban {
    cursor: not-allowed;
}

.uppercase {
    text-transform: uppercase;
}

.has-error {
    color: #dc3545;
}

.has-error input {
    border: 1px solid #dc3545 !important;
}

.has-error input:focus {
    border: 1px solid #dc3545;
    box-shadow: 0 0 0 0.15rem #F8E6E0 !important;
}

.has-error select {
    border: 1px solid #dc3545 !important;
}

.has-error select:focus {
    border: 1px solid #dc3545;
    box-shadow: 0 0 0 0.15rem #F8E6E0 !important;
}

.has-error small {
    float: left;
    margin-top: 5px;
    font-style: italic;
    font-size: 11px;
}

</style>
