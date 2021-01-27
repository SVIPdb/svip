<template>
    <div style="width: 100%;">
        <div ref="bodytext"> <!-- :style="`height: 20rem; overflow-y:scroll; resize: vertical;`" -->
            <b-overlay :show="loading" rounded="sm">
                <b-container
                    fluid
                    class="evidence"
                    v-if="variomes && pubData && !variomes.error"
                    @mouseup="citable && getSelectionText()"
                    @contextmenu="citable && handleRightClick($event)"
                    style="height: 600px;"
                >
                    <pmca-element ref="pmcaElem" style="width: 100%;" />
                </b-container>
                <div
                    v-else-if="variomes && (variomes.error || !pubData)"
                    class="text-center text-muted font-italic"
                >
                    <icon name="exclamation-triangle" scale="3" style="vertical-align: text-bottom; margin-bottom: 5px;" /><br />
                    We couldn't load the abstract due to a technical issue
                </div>
                <div v-else class="text-center">
                    <b-spinner label="Spinning" variant="primary" /> Loading
                </div>
            </b-overlay>
        </div>

        <div v-if="variomes && pubData && !variomes.error" class="ml-3 pt-1 border-top">
            <small>
                Source:
                <b-link v-bind="pubmedURL(pubData.id)">{{pubData.id}}</b-link>

                <span v-if="pmcViewerUrl">
                <span class="d-inline-block ml-1 mr-1">|</span>
                <b-link :href="pmcViewerUrl" class="bold" target="_blank">view full text on Variomes
                    <b-icon-box-arrow-up-right />
                </b-link>
                </span>
            </small>
        </div>
    </div>
</template>

<script>
import { pubmedURL } from "@/utils";
import { BIconBoxArrowUpRight } from "bootstrap-vue";

import '@/support/pmca/pmca-element';

export default {
    name: "VariomesFullText",
    components: { BIconBoxArrowUpRight },
    props: {
        variomes: { required: true },
        citable: { type: Boolean, default: false }
    },
    data() {
        return {
            selection: null,
            tries: 0,
            loading: false
        }
    },
    mounted() {
        const pmcaElem = this.$refs.pmcaElem;
        this.tries = 0;

        if (pmcaElem) {
            this.loadPMC(this.pubData.id);
        }
        else {
            console.warn("PMCA elem doesn't exist at mount!")
        }
    },
    computed: {
        pubData() {
            return (
                this.variomes && this.variomes.publications && this.variomes.publications.length > 0 &&
                !this.variomes.publications[0].error
            )
                ? this.variomes.publications[0]
                : null;
        },
        pmcViewerUrl() {
            if (!this.pubData || this.pubData.collection !== 'pmc') {
                return null;
            }

            return `https://candy.hesge.ch/pmca/index.html?pmcid=${this.pubData.id.replace('PMC', '')}`
        }
    },
    methods: {
        pubmedURL,
        getSelectionText() {
            if (window.getSelection) {
                this.selection = window.getSelection().toString();
            } else {
                this.selection = "";
            }
        },
        loadPMC(pmcid) {
            if (this.$refs.pmcaElem && this.$refs.pmcaElem.fillViewerWithIdAndOptions) {
                this.loading = true;
                this.$refs.pmcaElem.fillViewerWithIdAndOptions(pmcid, {service: "httpcandy"}).finally(() => {
                    console.log("done loading!");
                    this.loading = false;
                });
            }
            else {
                if (this.tries < 3) {
                    console.warn(`Unable to load PMCID ${pmcid} due to the viewer not existing, trying again in 300ms... (remaining tries: ${3 - this.tries}`);
                    this.tries += 1;
                    setTimeout(() => {
                        this.loadPMC(pmcid);
                    }, 300);
                }

            }
        },
        handleRightClick(event) {
            event.stopPropagation();
            event.preventDefault();
            this.$emit('showmenu', { event, selection: this.selection });
        }
    }
}
</script>

<style scoped>

</style>
