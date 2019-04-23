<template>
	<div>
			<span v-for="(x, idx) in listifyCounts" :key="idx">
				<span v-if="idx !== 0">{{', '}}</span>
				{{ x.count }} {{ x.name }} <span class="percent">({{ x.percent }}%)</span>
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

			/*
          return this.data.map(x => {
              const subsigs = x.subsigs ? " (" + x.subsigs.map(z => `${z.count} ${z.name}`).join(", ") + ")" : '';
                return `<b>${x.count} ${x.name}</b>${subsigs} <span class="percent">(${}%)</span>`
            }).join(", ")
         */
		}
	}
}
</script>

<style scoped>
.percent {
	color: #777;
	margin-left: 0.1em;
}
</style>
