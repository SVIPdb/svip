<template>
	<span class="source-icon">
		<img ref="the_icon" :src="source.icon" :alt="source.name" :style="style" />
		<b-tooltip v-if="!noTip" :target="() => $refs.the_icon" placement="top">
			{{ source.name }}
		</b-tooltip>
	</span>
</template>

<script>
const sources = {
	svip: { name: 'SVIP', icon: require('@/assets/icons/svip_small_icon.png') },
	civic: { name: 'CIViC', icon: require('@/assets/icons/civic_icon.png') },
	oncokb: { name: 'OncoKB', icon: require('@/assets/icons/oncokb-194x194-bw.png') },
	cosmic: { name: 'COSMIC', icon: require('@/assets/icons/cosmic-196x196-bw.png') }
};

export default {
	name: "SourceIcon",
	props: {
		name: { type: String, required: true },
		noTip: { type: Boolean, default: false },
		size: { type: Number, default: 16 },
		marginRight: { type: Number, default: 5 },
	},
	computed: {
		source() {
			return sources[this.name];
		},
		style() {
			return `width: ${this.size}px; margin-right: ${this.marginRight}px;`;
		}
	}
}
</script>

<style scoped>
.source-icon {
	display: inline-block;
}
</style>
