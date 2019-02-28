<template>
	<div class="row">
		<Pathogenicity :cadd="mvInfo.cadd" v-if="mvInfo && mvInfo.cadd"/>
		<PopulationStats :mvInfo="mvInfo" v-if="mvInfo"/>
	</div>
</template>

<script>
import Pathogenicity from "./Pathogenicity";
import PopulationStats from "./PopulationStats";

export default {
	name: "VariantExternalInfo",
	components: {Pathogenicity, PopulationStats},
	props: ["mvInfo"]
};
</script>

<style scoped></style>
