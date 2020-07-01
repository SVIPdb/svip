
<template>
	<span>
		<a ref="anchor" :id="`link-${auto_id}`" :href="url" target="_blank" @click="openReference">{{ title }}</a>

		<b-popover
            :target="() => $refs.anchor"
            triggers="hover focus"
            data-container="body"
            @show="updateCitation"
        >
			<template>
				<div v-if="variomes && variomesIsValid"
                    :class="['variomes-popover', (variomes && single_publication && single_publication.abstract_highlight.length < 30) ? 'short-abstract' : null]">
					<h6 class="title" v-html="single_publication.title_highlight"></h6>
					<div class="authors">{{ formatAuthors(single_publication.authors) }}. {{ single_publication.journal }} ({{ single_publication.date }})</div>
					<div class="abstract" v-html="single_publication.abstract_highlight"></div>

					<div class="abstract-fader"></div>
				</div>
				<div v-else-if="variomes && error">{{ error }}</div>
				<span v-else class="variomes-loading">
                    <b-spinner variant="secondary" style="width: 1rem; height: 1rem; margin-right: 5px;" /> loading...
				</span>
			</template>
		</b-popover>
	</span>
</template>

<script>
import { HTTP } from '@/router/http';
import ulog from 'ulog'

const log = ulog('VariomesLitPopover');

// FIXME: eventually link to http://variomes.hesge.ch/Variomes/literature.jsp?id=27145535&gene=NRAS&variant=Q61R

let ids = 0;

export default {
    name: "VariomesLitPopover",
    props: {
        pubmeta: {type: Object, required: false},
        pmid: {type: String, required: false},
        gene: {type: String},
        variant: {type: String},
        disease: {type: String},
        deferred: {type: Boolean, default: false},
        content: { required: false }
    },
    data() {
        return {
            auto_id: ids++,
            variomes: null,
            error: null
        }
    },
    created() {
        if (this.content) {
            // we were pre-filled with content, so just "update" to that
            this.variomes = this.content;
        }

        if (!this.deferred) {
            this.updateCitation();
        }
    },
    computed: {
        parsedPMID() {
            const target = ((this.pmid) ? this.pmid : this.pubmeta.pmid);
            return target && target.replace("PMID:", "");
        },
        url() {
            if (!this.parsedPMID) {
                return null;
            }

            return `http://www.ncbi.nlm.nih.gov/pubmed/${this.parsedPMID}`;
        },
        title() {
            if (this.pmid) { return this.parsedPMID }

            return this.pubmeta.title ? this.pubmeta.title : this.parsedPMID;
        },
        variomesIsValid() {
            return (
                this.variomes
                && this.parsedPMID
                && !this.error
                && this.variomes.publications
                && this.variomes.publications.length > 0
                && this.single_publication.id === this.parsedPMID
            );
        },
        single_publication() {
            return this.variomes && this.variomes.publications && this.variomes.publications[0];
        }
    },
    methods: {
        formatAuthors(authors) {
            if (authors.length > 5) {
                return authors.slice(0, 3).concat("et al").join(", ");
            }

            return authors.join(", ");
        },
        updateCitation() {
            // close all other popovers before showing this one
            this.$root.$emit('bv::hide::popover');

            // if it's already loaded, return immediately
            // (note that we need to check if the ids match because elements in a bootstrap-vue table are
            // retained when you change pages, causing their data to be shared between corresponding elements
            // on different pages...)
            if (this.variomesIsValid)
                return;

            this.error = null;
            HTTP.get(`variomes_single_ref`, {
                params: {
                    id: this.parsedPMID,
                    genvars: `${this.gene} (${this.variant})`,
                    disease: this.disease
                }
            })
                .then(response => {
                    this.variomes = response.data;
                })
                .catch((err) => {
                    log.warn(err);
                    this.error = {error: "Couldn't retrieve publication info, try again later."};
                });
        },
        openReference() {
            // hide all popovers before we continue, so that they don't remain open if middle-clicked
            this.$root.$emit('bv::hide::popover');
        }
    }
}
</script>

<style>
.variomes-popover .title { font-weight: bold; }

.variomes-popover .abstract { max-height: 30ex; overflow: hidden; }

.variomes-popover .authors { font-style: italic; margin-bottom: 0.25em; }

.variomes-popover .abstract-fader {
    position: absolute; left: 3px; right: 3px; bottom: 8px; height: 64px; background-color: transparent;
    background-image: linear-gradient(rgba(0, 0, 0, 0), white);
}

.variomes-popover.short-abstract .abstract-fader {
    display: none;
}

.variomes-loading { display: flex; align-items: center; justify-content: space-between; }

.variomes-popover .gene { color: #e3639f; font-weight: bold; }

.variomes-popover .variant { color: #4b7bef; font-weight: bold; }

.variomes-popover .disease { color: #3d811e; font-weight: bold; }
</style>
