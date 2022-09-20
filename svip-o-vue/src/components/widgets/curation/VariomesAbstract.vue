<template>
    <b-card no-body>
        <b-card-body>
            <div
                ref="bodytext"
                :style="`height: 20rem; overflow-y:scroll; resize: vertical; max-height: ${bodyHeight}px;`">
                <b-container
                    fluid
                    class="evidence"
                    v-if="variomes && pubData && !variomes.error"
                    @mouseup="citable && getSelectionText()"
                    @contextmenu="citable && handleRightClick($event)">
                    <h5 class="font-weight-bolder" v-html="pubData.title_highlight" />
                    <div>{{ pubData.date }}</div>
                    <p>
                        <b-link
                            v-bind="pubmedURL(`?term=${author}[Author]`)"
                            v-for="(author, index) in pubData.authors"
                            :key="index">
                            {{ author + (index < pubData.authors.length - 1 ? ', ' : '') }}
                        </b-link>
                    </p>
                    <b>Abstract</b>
                    <p class="text-justify" v-html="pubData.abstract_highlight" />
                </b-container>
                <div
                    v-else-if="variomes && (variomes.error || !pubData)"
                    class="text-center text-muted font-italic">
                    <icon
                        name="exclamation-triangle"
                        scale="3"
                        style="vertical-align: text-bottom; margin-bottom: 5px" />
                    <br />
                    We couldn't load the abstract due to a technical issue
                </div>
                <div v-else class="text-center">
                    <b-spinner label="Spinning" variant="primary" />
                    Loading
                </div>
            </div>

            <div v-if="variomes && pubData && !variomes.error" class="ml-3 pt-1 border-top">
                <small>
                    Source:
                    <b-link v-bind="pubmedURL(pubData.id)">{{ pubData.id }}</b-link>

                    <span v-if="pmcViewerUrl">
                        <span class="d-inline-block ml-1 mr-1">|</span>
                        <b-link :href="pmcViewerUrl" class="bold" target="_blank">
                            view full text on Variomes
                            <b-icon-box-arrow-up-right />
                        </b-link>
                    </span>
                </small>
            </div>
        </b-card-body>
    </b-card>
</template>

<script>
import {pubmedURL} from '@/utils';
import {BIconBoxArrowUpRight} from 'bootstrap-vue';

export default {
    name: 'VariomesAbstract',
    components: {BIconBoxArrowUpRight},
    props: {
        variomes: {required: true},
        citable: {type: Boolean, default: false},
    },
    data() {
        return {
            selection: null,
            bodyHeight: 500,
        };
    },
    computed: {
        pubData() {
            return this.variomes &&
                this.variomes.publications &&
                this.variomes.publications.length > 0 &&
                !this.variomes.publications[0].error
                ? this.variomes.publications[0]
                : null;
        },
        pmcViewerUrl() {
            if (!this.pubData || this.pubData.collection !== 'pmc') {
                return null;
            }

            return `https://candy.hesge.ch/pmca/index.html?pmcid=${this.pubData.id.replace('PMC', '')}`;
        },
    },
    watch: {
        variomes(newVal) {
            if (!newVal) {
                return;
            }

            this.$nextTick(() => {
                this.bodyHeight = Math.max(
                    this.$refs.bodytext
                        ? Array.from(this.$refs.bodytext.children).reduce(
                            (acc, x) => acc + x.offsetHeight,
                            0
                        ) + 20
                        : 500,
                    500
                );
            });
        },
    },
    methods: {
        pubmedURL,
        getSelectionText() {
            if (window.getSelection) {
                this.selection = window.getSelection().toString();
            } else {
                this.selection = '';
            }
        },
        handleRightClick(event) {
            event.stopPropagation();
            event.preventDefault();
            this.$emit('showmenu', {event, selection: this.selection});
        },
    },
};
</script>

<style scoped></style>
