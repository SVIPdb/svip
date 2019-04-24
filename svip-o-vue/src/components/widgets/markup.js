import Vue from "vue";

/* used in ViewVariant, and potentially also in ViewGene */
Vue.component("optional", {
	props: ["val"],
	template: `
    <td :class="{unavailable: !val}">
        <span v-if="val"><slot></slot></span>
        <span v-else>unavailable</span>
    </td>`
});

Vue.component("coordinates", {
	props: ["val"],
	template: `
    <optional :val="val">
        <span v-if="val"><span class="text-muted transcript-id">{{val.transcript}}:</span>&#x200b;{{val.change}}</span>
    </optional>`
});
