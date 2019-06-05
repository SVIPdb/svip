<template>
	<span>
		<a :id="`linked-${auto_id}`" :href="url" target="_blank">{{ title }}</a>

		<b-popover
			:target="`linked-${auto_id}`"
			triggers="hover focus"
			data-container="body"
		>
			<template>
				<div v-if="variomes && variomes.publication" class="variomes-popover">
					<h6 class="title" v-html="variomes.publication.title_highlight"></h6>
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
import store from "@/store";
import { HTTP } from '@/router/http';

// FIXME: eventually link to http://variomes.hesge.ch/Variomes/literature.jsp?id=27145535&gene=NRAS&variant=Q61R

// used to parse pubmed titles, which may contain html, for the hover-over tooltips
const parser = new DOMParser();

function parsePubMeta(pubmeta) {
	if (pubmeta.hasOwnProperty('pmid') && pubmeta.pmid) {
		// extract the PMID and convert it to a url, then return a { url, title } object
		const parsedPMID = parseInt(pubmeta.pmid.replace("PMID:", ""));

		return {
			url: `http://www.ncbi.nlm.nih.gov/pubmed/${parsedPMID}`,
			title: parsedPMID,
			pmid: parsedPMID
		}
	}

	// otherwise, it's a regular pubmeta object
	return pubmeta;
}

let ids = 0;

export default {
	name: "VariomesLitPopover",
	props: {
		pubmeta: {type: Object, required: true},
		gene: {type: String},
		variant: {type: String},
		disease: {type: String}
	},
	data() {
		return {
			auto_id: ids++,
			variomes: null,
			...parsePubMeta(this.pubmeta)
		}
	},
	created() {
		HTTP.get(`variomes_single_ref`, {
			params: {
				id: this.pubmeta.pmid,
				gene: this.gene,
				variant: this.variant,
				disease: this.disease
			}
		})
			.then(response => {
				this.variomes = response.data;
			})
			.catch((err) => {
				this.variomes = { error: "Couldn't retrieve publication info, try again later." };
			});
	},
	methods: {
	}
}
</script>

<style>
.variomes-popover .title { font-weight: bold; }
.variomes-popover .abstract { max-height: 30ex; overflow: hidden; }
.variomes-popover .abstract-fader {
	position: absolute; left: 3px; right: 3px; bottom: 8px; height: 64px; background-color: transparent;
	background-image: linear-gradient(rgba(0, 0, 0, 0), white);
}

.variomes-loading { display: flex; align-items: center; justify-content: space-between; }

.variomes-popover .gene { color: #e3639f; font-weight: bold; }
.variomes-popover .variant { color: #4b7bef; font-weight: bold; }
.variomes-popover .disease { color: #3d811e; font-weight: bold; }
</style>
