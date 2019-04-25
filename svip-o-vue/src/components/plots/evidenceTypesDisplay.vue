<template>
	<div>
			<span v-for="(x, idx) in listifyCounts" :key="idx">
				<span v-if="idx !== 0">{{', '}}</span>
				<span class="type-count">{{ x.count }} {{ x.name }}</span>
				<span v-if="x.subsigs" class="subsigs" v-html="joinSubSigs(x.subsigs)"></span>
				<span class="percent">({{ x.percent }}%)</span>
			</span>
	</div>
</template>

<script>
import round from 'lodash/round';

export default {
	name: "significanceTextDisplay",
	props: ["data"],
	computed: {
		listifyCounts() {
			const total = this.data.map(x => x.count).reduce((x, acc) => x+acc, 0);

			return this.data.map(x => ({
				...x,
				percent: round((x.count/total) * 100.0, 1)
			}));
		}
	},
	methods: {
		joinSubSigs(subsigs) {
			return " (" + subsigs.map(z => `<span class="type-count">${z.count} ${z.name}</span>`).join(", ") + ")"
		}
	}
}
</script>

<style scoped>
.type-count {
	white-space: nowrap;
}

.percent {
	color: #777;
	margin-left: 0.1em;
}

.subsigs {
	color: #555;
	font-style: italic;
	margin-right: 0.1em;
}
</style>
