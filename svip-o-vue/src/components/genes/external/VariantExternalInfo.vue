<template>
	<div class="row">
		<Pathogenicity :cadd="mvInfo.cadd" :dbnsfp="mvInfo.dbnsfp" :extras="extras" v-if="mvInfo && (mvInfo.cadd || mvInfo.dbnsfp || extras)"/>
		<PopulationStats :mvInfo="mvInfo" v-if="mvInfo"/>
	</div>
</template>

<script>
import Pathogenicity from "./Pathogenicity";
import PopulationStats from "./PopulationStats";

export default {
	name: "VariantExternalInfo",
	components: {Pathogenicity, PopulationStats},
	props: ["mvInfo", "extras"]
};
</script>

<style scoped></style>
