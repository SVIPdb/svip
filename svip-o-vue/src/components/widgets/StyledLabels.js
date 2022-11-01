import Vue from 'vue';

/* used in ViewVariant, and potentially also in ViewGene */
Vue.component('optional', {
    props: ['val'],
    template: `
    <td :class="{unavailable: !val}">
        <span v-if="val"><slot></slot></span>
        <span v-else>unavailable</span>
    </td>`,
});

// add &#x200b; in between transcript and change if you want it to wrap there
Vue.component('inline-coordinates', {
    props: ['val'],
    template: `<span @click="clicked" style="cursor: pointer;">
		<span v-if="val.change" :class="['coordinates', truncated && 'truncated']"><span class="text-muted transcript-id">{{val.transcript}}:</span>{{val.change}}</span>
		<span v-else class="unavailable">unavailable</span>
</span>`,
    data() {
        return {truncated: true};
    },
    methods: {
        clicked() {
            this.truncated = !this.truncated;
        },
    },
});

// add &#x200b; in between transcript and change if you want it to wrap there
Vue.component('wrapping-coordinates', {
    props: ['val'],
    template: `<span>
		<span v-if="val.change" class="coordinates"><span class="text-muted transcript-id">{{val.transcript}}:</span>&#x200b;{{val.change}}</span>
		<span v-else class="unavailable">unavailable</span>
</span>`,
});

Vue.component('coordinates', {
    props: ['val'],
    template: `
    <optional :val="val">
        <wrapping-coordinates v-if="val" :val="val" />
    </optional>`,
});
