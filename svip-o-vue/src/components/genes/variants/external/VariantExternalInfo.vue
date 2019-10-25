<template>
    <div class="row">
        <Pathogenicity v-if="included('Pathogenicity') && mvInfo && (mvInfo.cadd || mvInfo.dbnsfp || extras)"
            :cadd="mvInfo.cadd" :dbnsfp="mvInfo.dbnsfp" :extras="extras"/>
        <PopulationStats v-if="included('PopulationStats') && mvInfo" :mvInfo="mvInfo"/>
        <SwissPO v-if="included('SwissPO')" :protein="variant.gene.symbol" :uniprot-id="variant.gene.uniprot_ids[0]"
            :change="variant.name"/>
        <SOCIBP v-if="included('SOCIBP')" :protein="variant.gene.symbol" :change="variant.name"/>
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
    props: ["variant", "mvInfo", "extras", "exclude"],
    methods: {
        included(componentName) {
            // returns true if no exclusions are specified, or if this component wasn't named in the exclusion list
            return !this.exclude || !this.exclude.includes(componentName);
        }
    }
};
</script>

<style scoped></style>
