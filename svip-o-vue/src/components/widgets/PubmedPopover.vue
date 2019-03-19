<template>
	<a :href="pubmeta.url" target="_blank" v-b-popover.html.hover="pubmedPopover">{{ pubmeta.title }}</a>
</template>

<script>
import store from "@/store";

// used to parse pubmed titles, which may contain html, for the hover-over tooltips
const parser = new DOMParser();

export default {
  name: "PubmedPopover",
	props: {pubmeta: {type: Object, required: true}},
	methods: {
		pubmedPopover(elem) {
			const pmid = parseInt(elem.text);
			const itemData = store.state.genes.pubmedInfo[pmid];

			if (!itemData) {
				if (!isNaN(pmid)) {
					// console.log("Attempting fetch of " + pmid)
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
