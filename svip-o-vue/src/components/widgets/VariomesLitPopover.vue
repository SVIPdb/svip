<template>
	<span>
		<a ref="anchor" :href="url" target="_blank">{{ title }}</a>

		<b-popover
            :target="() => $refs.anchor"
            triggers="hover focus"
            data-container="body"
            @show="updateCitation"
        >
			<template>
				<div v-if="variomes && variomes.publication"
                    :class="['variomes-popover', (variomes && variomes.publication && variomes.publication.abstract_highlight.length < 30) ? 'short-abstract' : null]">
					<h6 class="title" v-html="variomes.publication.title_highlight"></h6>
					<div class="authors">{{ formatAuthors(variomes.publication.authors) }}. {{ variomes.publication.journal }} ({{ variomes.publication.date }})</div>
					<div class="abstract" v-html="variomes.publication.abstract_highlight"></div>

					<div class="abstract-fader"></div>
				</div>
				<div v-else-if="variomes && variomes.error">{{ variomes.error }}</div>
				<span v-else class="variomes-loading">
					<icon name="spinner" pulse></icon> &nbsp; loading...
				</span>
			</template>
		</b-popover>
	</span>
</template>

<script>
import {HTTP} from '@/router/http';

// FIXME: eventually link to http://variomes.hesge.ch/Variomes/literature.jsp?id=27145535&gene=NRAS&variant=Q61R

export default {
    name: "VariomesLitPopover",
    props: {
        pubmeta: {type: Object, required: false},
        pmid: {type: String, required: false},
        gene: {type: String},
        variant: {type: String},
        disease: {type: String},
        deferred: {type: Boolean, default: false}
    },
    data() {
        return {
            variomes: null
        }
    },
    created() {
        if (!this.deferred) {
            this.updateCitation();
        }
    },
    computed: {
        parsedPMID() {
            return ((this.pmid) ? this.pmid : this.pubmeta.pmid).replace("PMID:", "");
        },
        url() {
            return `http://www.ncbi.nlm.nih.gov/pubmed/${this.parsedPMID}`;
        },
        title() {
            if (this.pmid) { return this.parsedPMID }

            return this.pubmeta.title ? this.pubmeta.title : this.parsedPMID;
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
            // if it's already loaded, return immediately
            // (note that we need to check if the ids match because elements in a bootstrap-vue table are
            // retained when you change pages, causing their data to be shared between corresponding elements
            // on different pages...)
            if (this.variomes && !this.variomes.error && this.variomes.publication.id === this.parsedPMID)
                return;

            HTTP.get(`variomes_single_ref`, {
                params: {
                    id: this.parsedPMID,
                    gene: this.gene,
                    variant: this.variant,
                    disease: this.disease
                }
            })
                .then(response => {
                    this.variomes = response.data;
                })
                .catch((err) => {
                    this.variomes = {error: "Couldn't retrieve publication info, try again later."};
                });
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
