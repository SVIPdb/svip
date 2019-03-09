<template functional>
	<span>{{ props.row.item.scores }}</span>
</template>

<script>
export default {
	name: "CosmicScoresCol",
	props: {
		row: { type: Object, required: true }
	}
}
</script>

<style scoped>

</style>
