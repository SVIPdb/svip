<template>
    <div class="container-fluid">
        <div class="grid">
            <!--
            <isotope :options="isotopeOptions" :list="componentList">
                <div class="col-sm-auto" v-for="c in componentList" :key="c.name">
                    <component v-if="c.vIf" v-bind:is="c.type" v-bind="c.props" />
                </div>
            </isotope>
            -->

            <div :class="`grid-sizer ${sharedClasses}`"></div>

            <Pathogenicity v-if="included('Pathogenicity') && mvInfo && (mvInfo.cadd || mvInfo.dbnsfp || extras)"
                :class="`grid-item ${sharedClasses}`"
                :cadd="mvInfo.cadd" :dbnsfp="mvInfo.dbnsfp" :extras="extras"
            />

            <PopulationStats v-if="included('PopulationStats') && mvInfo"
                :class="`grid-item ${sharedClasses}`"
                :mvInfo="mvInfo"
            />

            <SwissPO v-if="included('SwissPO')"
                :class="`grid-item ${sharedClasses}`"
                :protein="variant.gene.symbol"
                :uniprot-id="variant.gene.uniprot_ids[0]"
                :change="variant.name"
            />

            <SOCIBP v-if="included('SOCIBP')"
                :class="`grid-item ${sharedClasses}`"
                :protein="variant.gene.symbol"
                :change="variant.name"
                @updated="relayout"
            />
        </div>
    </div>
</template>

<script>
import Isotope from 'isotope-layout';
import Pathogenicity from "./Pathogenicity";
import PopulationStats from "./PopulationStats";
import SwissPO from "@/components/genes/variants/external/SwissPO";
import SOCIBP from "@/components/genes/variants/external/SOCIBP";

export default {
    name: "VariantExternalInfo",
    components: {SwissPO, Pathogenicity, PopulationStats, SOCIBP, Isotope},
    props: ["variant", "mvInfo", "extras", "exclude"],
    data() {
        return {
            iso: null,
            sharedClasses: "col-md-12 col-lg-6 col-xl-3"
        }
    },
    mounted() {
        this.iso = new Isotope('.grid', {
            itemSelector: '.grid-item', // use a separate class for itemSelector, other than .col-
            percentPosition: true,
            masonry: {
                columnWidth: '.grid-sizer'
            }
        });
    },
    beforeDestroy() {
        // TODO: destroy isotope?
    },
    methods: {
        included(componentName) {
            // returns true if no exclusions are specified, or if this component wasn't named in the exclusion list
            return !this.exclude || !this.exclude.includes(componentName);
        },
        relayout() {
            if (this.iso) {
                this.$nextTick(() => {
                    console.log("Triggering layout");
                    this.iso.layout();
                });
            }
        }
    }
};
</script>

<style scoped></style>
