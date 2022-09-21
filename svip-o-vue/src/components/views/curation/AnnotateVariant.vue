<template>
    <div class="container-fluid">
        <CuratorVariantInformations :variant="variant" :disease_id="disease_id" />

        <CurationGeneSummary :gene="gene" />

        <CurationVariantSummary :variant="variant" />

        <EvidenceCard :variant="variant" is-submittable small />

        <!--<b-button class="float-right redirection-button" :to="{ name: 'annotate-review' }" @click="redirect">
            See submitted annotations
        </b-button>
        <br/><br/><br/>-->

        <div>
            <b-card no-body>
                <b-tabs
                    card
                    justified
                    nav-wrapper-class="bg-primary"
                    nav-class="text-white"
                    active-nav-item-class="font-weight-bolder">
                    <b-tab title="Enter your reference" active>
                        <b-card-body>
                            <b-container>
                                <b-row no-gutters>
                                    <b-col cols="3">
                                        <b-form-select
                                            required
                                            class="custom-border-left"
                                            v-model="source"
                                            :options="['PMID']" />
                                    </b-col>
                                    <b-col cols="6">
                                        <b-form-input
                                            v-model="reference"
                                            required
                                            placeholder="Type reference"
                                            class="rounded-0" />
                                    </b-col>
                                    <b-col cols="2">
                                        <b-button-group>
                                            <b-button
                                                :disabled="!source || !reference"
                                                class="custom-unrounded centered-icons"
                                                variant="info"
                                                @click="viewCitation">
                                                <icon name="eye" />
                                                View Abstract
                                            </b-button>
                                            <b-button
                                                :disabled="!source || !reference"
                                                type="submit"
                                                class="custom-border-right centered-icons"
                                                variant="success"
                                                @click="addEvidence"
                                                target="_blank">
                                                <icon name="plus" />
                                                Create Entry
                                            </b-button>
                                        </b-button-group>
                                    </b-col>
                                </b-row>

                                <transition name="slide-fade" mode="out-in">
                                    <MessageWithIcon v-if="annotationUsed" class="mt-4 mr-5 ml-5">
                                        <template v-slot:icon>
                                            <icon name="exclamation-triangle" scale="2.5" />
                                        </template>
                                        <template>
                                            This reference has already been used in other entries:

                                            <EntriesInUse :annotation-used="annotationUsed" />
                                        </template>
                                    </MessageWithIcon>
                                </transition>

                                <b-row no-gutters>
                                    <b-col cols="12">
                                        <VariomesAbstract
                                            v-if="loadingVariomes"
                                            style="margin-top: 1em"
                                            :variomes="variomes" />
                                    </b-col>
                                </b-row>
                            </b-container>
                        </b-card-body>
                    </b-tab>

                    <b-tab title="Use text mining tool">
                        <VariomesSearch
                            :gene="gene"
                            :variant="variant"
                            :used_references="used_references"
                            @add-evidence-from-list="addEvidenceFromList" />
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
import {mapGetters} from 'vuex';
import CuratorVariantInformations from '@/components/widgets/curation/CuratorVariantInformations';
import EvidenceCard from '@/components/widgets/curation/EvidenceCard';
import store from '@/store';
import {desnakify} from '@/utils';
import {HTTP} from '@/router/http';
import VariomesSearch from '@/components/widgets/curation/VariomesSearch';
import VariomesAbstract from '@/components/widgets/curation/VariomesAbstract';
import CurationVariantSummary from '@/components/widgets/curation/CurationVariantSummary';
import CurationGeneSummary from '@/components/widgets/curation/CurationGeneSummary';
import ulog from 'ulog';
import BroadcastChannel from 'broadcast-channel';
import MessageWithIcon from '@/components/widgets/MessageWithIcon';
import EntriesInUse from '@/components/widgets/curation/AnnotationsInUse';

const log = ulog('Curation:AnnotateVariant');

export default {
    name: 'AnnotateVariant',
    components: {
        EntriesInUse,
        MessageWithIcon,
        CurationGeneSummary,
        CurationVariantSummary,
        VariomesSearch,
        VariomesAbstract,
        CuratorVariantInformations,
        EvidenceCard,
    },
    data() {
        return {
            channel: new BroadcastChannel('curation-update'),
            source: 'PMID',
            reference: '',
            loadingVariomes: false,
            variomes: null,
            used_references: {},
        };
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
            variant: 'variant',
            gene: 'gene',
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
            HTTP.get('/curation_entries/all_references').then(response => {
                this.used_references = response.data.references;
            });
        },
        addEvidence() {
            let route = this.$router.resolve({
                name: 'add-evidence',
                params: {
                    action: 'add',
                },
                query: {
                    source: this.reference && this.reference.includes('PMC') ? 'PMC' : 'PMID',
                    reference: this.reference,
                    variant_id: this.$route.params.variant_id,
                    disease_id: this.$route.params.disease_id,
                },
            });
            window.open(route.href, '_blank');
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
                    genvars: `${this.variant.gene.symbol} (${this.variant.name})`,
                    collection: this.reference.includes('PMC')
                        ? 'pmc'
                        : this.reference.includes('NCT')
                            ? 'ct'
                            : undefined,
                    hl_fields: 'title,abstract',
                },
            })
                .then(response => {
                    this.variomes = response.data;
                    // this.loadingVariomes = false;
                })
                .catch(err => {
                    log.warn(err);
                    this.variomes = {
                        error: "Couldn't retrieve publication info, try again later.",
                    };
                    // this.loadingVariomes = false;
                });
        },
        redirect() {
            window.location.href = `${window.location.href}/submit/`;
        },
    },
    beforeRouteEnter(to, from, next) {
        const {variant_id} = to.params;

        // ask the store to populate detailed information about this variant
        store.dispatch('getGeneVariant', {variant_id: variant_id}).then(({gene, variant}) => {
            to.meta.title = `SVIP-O: Annotate ${gene.symbol} ${variant.name}`;
            next();
        });
    },
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

.gene {
    color: #e3639f;
    font-weight: bold;
}
.variant {
    color: #4b7bef;
    font-weight: bold;
}
.disease {
    color: #3d811e;
    font-weight: bold;
}
.redirection-button {
    margin-bottom: 2px;
    display: block;
}
</style>
