<template>
	<b-card-text>
		<b-table :fields="fields" :items="row.item.curation_entries" :show-empty="true" :small="true">
			<template slot="references" slot-scope="data">
				<VariomesLitPopover
					:pubmeta="{ pmid: trimPrefix(data.value, 'PMID:') }" :variant="variant.name" :gene="variant.gene.symbol" :disease="row.item.name"
				/>
			</template>

			<template slot="empty">
				<div class="empty-table-msg">- no evidence items -</div>
			</template>
		</b-table>
	</b-card-text>
</template>

<script>
import VariomesLitPopover from "@/components/widgets/VariomesLitPopover";
import {trimPrefix} from "@/utils";

export default {
  name: "EvidenceTable",
	components: {VariomesLitPopover},
	props: {
  	variant: { required: true, type: Object },
  	row: { required: true, type: Object }
	},
	data() {
  	return {
			fields: [
				{ key: "type_of_evidence", label: "Evidence Type", sortable: true },
				{ key: "effect", label: "Effect", sortable: true },
				{ key: "drug", label: "Drug", sortable: true },
				{ key: "tier_level_criteria", label: "Tier Criteria", sortable: true },
				{ key: "mutation_origin", label: "Mutation Origin", sortable: true },
				{ key: "summary", label: "Complementary Information", sortable: false },
				{ key: "support", label: "Support", sortable: true },
				{ key: "references", label: "References", sortable: false },
			]
		}
	},
	methods: {
  	trimPrefix
	}
}
</script>

<style scoped>

</style>
