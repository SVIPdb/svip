<template>
    <div class="container-fluid">
        <CuratorVariantInformations :variant="variant" :disease_id="disease_id" />

        <ModifyVariantSummary :variant="variant" :comments="summary.comments"/>

        <VariantDisease :variant="variant"/>
    </div>
</template>
<script>
import { mapGetters } from "vuex";
import CuratorVariantInformations from "@/components/widgets/curation/CuratorVariantInformations";
import store from "@/store";
import { desnakify } from "@/utils";
import { HTTP } from "@/router/http";
import ModifyVariantSummary from "@/components/widgets/review/ModifyVariantSummary";
import VariantDisease from "@/components/widgets/review/VariantDisease";
import ulog from 'ulog';
import BroadcastChannel from "broadcast-channel";

const log = ulog('SubmitCurations');

export default {
    name: "SubmitCurations",
    components: {
        ModifyVariantSummary,
        VariantDisease,
        CuratorVariantInformations
    },
    data() {
        return {
            channel: new BroadcastChannel("curation-update"),
            source: "PMID",
            reference: "",
            loadingVariomes: false,
            variomes: null,
            used_references: {},
            summary: {
                content: "",
                comments: []
            },
        }
    },
    mounted() {
        HTTP.get(`/summary_comments/?variant=${this.variant.id}`).then((response) => {
            const results = response.data.results
            this.summary.comments = results;
        });
    },
    created() {
        this.refreshReferences();

        this.channel.onmessage = () => {
            // update the list of references, since we likely added one
            this.refreshReferences();
        };
    },
    computed: {
        ...mapGetters({
            variant: "variant",
            gene: "gene"
        }),
        disease_id() {
            return parseInt(this.$route.params.disease_id);
        },
        annotationUsed() {
            if (!this.source || !this.reference) {
                return null;
            }

            const thisRef = `${this.source.trim()}:${this.reference.trim()}`;
            return this.used_references[thisRef];
        },
    },
    methods: {
        desnakify,
        refreshReferences() {
            // get a list of used references so we can tell the user if they're about to use one that's been used already
            HTTP.get('/curation_entries/all_references').then((response) => {
                this.used_references = response.data.references;
            })
        },
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
        },
        viewCitation() {
            // look up the reference via the variomes API
            this.loadingVariomes = true;

            // FIXME: we should ensure that we have a variant before we fire this off somehow...
            HTTP.get(`variomes_single_ref`, {
                params: {
                    id: this.reference.trim(),
                    genvars: `${this.variant.gene.symbol} (${this.variant.name})`
                }
            })
                .then(response => {
                    this.variomes = response.data;
                    // this.loadingVariomes = false;
                })
                .catch((err) => {
                    log.warn(err);
                    this.variomes = {
                        error: "Couldn't retrieve publication info, try again later."
                    };
                    // this.loadingVariomes = false;
                });
        }
    },
    beforeRouteEnter(to, from, next) {
        const { variant_id } = to.params;

        // ask the store to populate detailed information about this variant
        store.dispatch("getGeneVariant", { variant_id: variant_id }).then(({ gene, variant }) => {
            to.meta.title = `SVIP-O: Annotate ${gene.symbol} ${variant.name}`;
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

.custom-unrounded {
    border-radius: 0 !important;
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
