<template>
	<a :href="url" target="_blank" v-b-popover.html.hover="pubmedPopover">{{ title }}</a>
</template>

<script>
import store from "@/store";

// used to parse pubmed titles, which may contain html, for the hover-over tooltips
const parser = new DOMParser();

export default {
	name: "PubmedPopover",
	props: {pubmeta: {type: Object, required: true}},
	data() {
		if (this.pubmeta.hasOwnProperty('pmid')) {
			// extract the PMID and convert it to a url, then return a { url, title } object

			return {
				url: this.pubmeta.pmid.replace("PMID:", "http://www.ncbi.nlm.nih.gov/pubmed/"),
				title: this.pubmeta.pmid.replace("PMID:", ""),
				pmid: parseInt(this.pubmeta.pmid.replace("PMID:", ""))
			}
		}

		// otherwise, it's a regular pubmeta object
		return this.pubmeta;
	},
	created() {
		// we're using a timeout here to give the batched pubmed request in the evidence item providers
		// a chance to complete before we try to fire off our own individual request.
		// it's unclear how long we should wait for the batched request to complete -- 1 second is extremely
		// conservative, and may lead to the user not seeing the citation info if they immediately try to mouse
		// over the item.

		// FIXME: in the future, the pubmed get action should defer on single requests, batching them together
		//  automatically if they arrive within a sufficiently short window.

		setTimeout(() => {
			// ensure that the pubmed cache has information about this citation
			const itemData = store.state.genes.pubmedInfo[this.pmid];

			if (!itemData) {
				if (!isNaN(this.pmid)) {
					store.dispatch('getPubmedInfo', { pmid: this.pmid });
				}
			}
		}, 1000);
	},
	methods: {
		pubmedPopover() {
			const pmid = this.pmid;
			const itemData = store.state.genes.pubmedInfo[pmid];

			if (!itemData) {
				if (!isNaN(pmid)) {
					store.dispatch('getPubmedInfo', {pmid});
					return `<i>No PubMed data found or loaded for this citation, try again in a little bit.</i>`;
				}
				else {
					return '';
				}
			}

			// console.log("Item data: ", JSON.parse(JSON.stringify(itemData)));

			let authorList = itemData.authors.map(n => n.name);
			if (authorList.length > 5) {
				authorList = authorList.slice(0, 5).concat("et al.")
			}

			// parse title as HTML, since apparently people like to embed html in their titles...
			const parsedTitle = parser.parseFromString(itemData.title, 'text/html');

			return `
<div>
<h6 style="font-weight: bold;">${parsedTitle.body.innerText}</h6>
<i>${authorList.join('; ')}</i>
</div>`;

		}
	}
}
</script>

<style scoped>

</style>
