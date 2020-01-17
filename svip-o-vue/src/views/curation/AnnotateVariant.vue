<template>
    <div class="container-fluid">
        <CuratorVariantInformations :variant="variant" :disease_id="disease_id" />
        <EvidenceCard :variant="variant" :disease_id="disease_id" is-submittable />
        <div>
            <b-card no-body>
                <b-tabs
                    card
                    justified
                    nav-wrapper-class="bg-primary"
                    nav-class="text-white"
                    active-nav-item-class="font-weight-bolder"
                >
                    <b-tab title="Enter your reference" active>
                        <b-card-body>
                            <b-container>
                                <b-row no-gutters>
                                    <b-col cols="5">
                                        <b-form-select required class="custom-border-left" v-model="source" :options="['PMID']"/>
                                    </b-col>
                                    <b-col cols="5">
                                        <b-form-input
                                            v-model="reference"
                                            required
                                            placeholder="Type reference"
                                            class="rounded-0"
                                        />
                                    </b-col>
                                    <b-col cols="2">
                                        <b-button :disabled="source == null || reference == null" type="submit" block class="custom-border-right centered-icons" variant="success" @click="addEvidence" target="_blank">
                                            <icon name="plus" /> Create Entry
                                        </b-button>
                                    </b-col>
                                </b-row>
                            </b-container>
                        </b-card-body>
                    </b-tab>

                    <b-tab title="Use text mining tool">
                        <VariomesSearch :gene="gene" :variant="variant" @add-evidence-from-list="addEvidenceFromList" />
                    </b-tab>

                    <!--
                    <b-tab title="Use prediction tools">
                        <b-card-text class="text-center">
                            <h1 class="display-2">Oops!</h1>Something went wrong here. We're working on it and we'll get it fixed as soon as possible.
                        </b-card-text>
                    </b-tab>
                    -->
                </b-tabs>
            </b-card>
        </div>
    </div>
</template>
<script>
import { mapGetters } from "vuex";
import CuratorVariantInformations from "@/components/curation/widgets/CuratorVariantInformations";
import VariomesLitPopover from "@/components/widgets/VariomesLitPopover";
import EvidenceCard from "@/components/curation/widgets/EvidenceCard";
import store from "@/store";
import { change_from_hgvs, desnakify, var_to_position } from "@/utils";
import { HTTP } from "@/router/http";
import VariomesSearch from "@/components/curation/widgets/VariomesSearch";

export default {
    name: "AnnotateVariant",
    components: {
        VariomesSearch,
        CuratorVariantInformations,
        VariomesLitPopover,
        EvidenceCard
    },
    data() {
        return {
            source: "PMID",
            reference: ""
        }
    },
    computed: {
        ...mapGetters({
            variant: "variant",
            gene: "gene"
        }),
        disease_id() {
            return parseInt(this.$route.params.disease_id);
        }
    },
    methods: {
        desnakify,
        addEvidence() {
            let route = this.$router.resolve({
                name: "add-evidence",
                params: {
                    gene_id: this.$route.params.gene_id,
                    variant_id: this.$route.params.variant_id,
                    disease_id: this.$route.params.disease_id,
                    action: 'add'
                },
                query: { source: this.source, reference: this.reference }
            });
            window.open(route.href, "_blank");
        },
        addEvidenceFromList(id) {
            this.reference = id;
            return this.addEvidence();
        }
    },
    beforeRouteEnter(to, from, next) {
        const { variant_id } = to.params;

        // ask the store to populate detailed information about this variant
        store.dispatch("getGeneVariant", { variant_id: variant_id }).then(() => {
            next();
        });
    }
};
</script>

<style>
.variant-card .card-body {
    padding: 0;
}
.variant-header {
    margin-bottom: 0;
}

.variant-header td,
.variant-header th {
    vertical-align: text-bottom;
    padding: 1rem;
}
.aliases-list {
    font-style: italic;
}

.details-row {
    background: #eee;
    box-shadow: inset;
}

/* Enter and leave animations can use different */
/* durations and timing functions.              */
.slide-fade-enter-active {
    transition: all 0.5s ease;
}
.slide-fade-leave-active {
    transition: all 0.3s ease;
}
.slide-fade-enter-to,
.slide-fade-leave {
    max-height: 120px;
}
.slide-fade-enter, .slide-fade-leave-to
    /* .slide-fade-leave-active below version 2.1.8 */ {
    opacity: 0;
    max-height: 0;
}

.custom-style .dropdown-toggle {
    border-radius: 0 !important;
    height: calc(2.15625rem + 2px) !important;
}

.custom-border-left {
    border-radius: 0.25rem 0 0 0.25rem !important;
}

.custom-border-right {
    border-radius: 0 0.25rem 0.25rem 0 !important;
}

.dotted-line {
    border-bottom: dotted 1px #555;
    padding-bottom: 2px;
}
</style>
