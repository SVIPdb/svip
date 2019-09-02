<template>
	<div class="row">
		<Pathogenicity :cadd="mvInfo.cadd" :dbnsfp="mvInfo.dbnsfp" :extras="extras" v-if="mvInfo && (mvInfo.cadd || mvInfo.dbnsfp || extras)"/>
		<PopulationStats :mvInfo="mvInfo" v-if="mvInfo"/>
    <SwissPO :protein="variant.gene.symbol" :uniprot-id="variant.gene.uniprot_ids[0]" :change="variant.name" />
    <SOCIBP :protein="variant.gene.symbol" :change="variant.name" />
	</div>
</template>

<script>
import Pathogenicity from "./Pathogenicity";
import PopulationStats from "./PopulationStats";
import SwissPO from "@/components/genes/variants/external/SwissPO";
import SOCIBP from "@/components/genes/variants/external/SOCIBP";

export default {
	name: "VariantExternalInfo",
	components: {SwissPO, Pathogenicity, PopulationStats, SOCIBP},
	props: ["variant", "mvInfo", "extras"]
};
</script>

<style scoped></style>
