<template>
	<!--
  /************************ LICENCE ***************************
  *     This file is part of <ViKM Vital-IT Knowledge Management web application>
  *     Copyright (C) <2016> SIB Swiss Institute of Bioinformatics
  *
  *     This program is free software: you can redistribute it and/or modify
  *     it under the terms of the GNU Affero General Public License as
  *     published by the Free Software Foundation, either version 3 of the
  *     License, or (at your option) any later version.
  *
  *     This program is distributed in the hope that it will be useful,
  *     but WITHOUT ANY WARRANTY; without even the implied warranty of
  *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  *     GNU Affero General Public License for more details.
  *
  *     You should have received a copy of the GNU Affero General Public License
  *    along with this program.  If not, see <http://www.gnu.org/licenses/>
  *
  *****************************************************************/
  -->

	<div class="container">
		<div class="card gene-summary">
			<div class="card-body">
				<h5 class="card-title">
					<b>{{ gene.symbol }}:</b> {{ totalRows }} variants
				</h5>

				<h6 v-if="gene.oncogene">Oncogene</h6>

				<table class="gene-info-items">
					<tr>
						<td class="text-right row-label">Entrez ID</td>
						<td>
							<a :href=" `https://www.ncbi.nlm.nih.gov/gene/?term=${ gene.entrez_id }%5Buid%5D`" target="_blank">{{ gene.entrez_id }}</a>
						</td>
					</tr>
					<tr>
						<td class="text-right row-label">Ensembl Gene ID</td>
						<td>
							<a :href=" `http://www.ensembl.org/Homo_sapiens/Gene/Summary?db=core;g=${ gene.ensembl_gene_id }`" target="_blank">{{ gene.ensembl_gene_id }}</a>
						</td>
					</tr>
					<tr>
						<td class="text-right row-label">UniProtKB ID</td>
						<td>
							<a v-if="gene.uniprot_ids" :href=" `https://www.uniprot.org/uniprot/${ gene.uniprot_ids[0] }`" target="_blank" class="mr-3">{{ gene.uniprot_ids[0] }}</a>
						</td>
					</tr>
				</table>
			</div>
		</div>

		<div class="row align-items-baseline">
			<div class="col">
				<b-form-group label-cols="2" label="Filter">
					<b-input-group>
						<b-form-input v-model="currentFilter.search" placeholder="Type to Search"/>
						<b-input-group-append>
							<b-btn :disabled="!currentFilter.search" @click="currentFilter.search = ''">Clear</b-btn>
						</b-input-group-append>
					</b-input-group>
				</b-form-group>
			</div>

			<div class="col text-right">
				<b-checkbox v-model="showOnlySVIP"><span id="show-svip-vars">show only SVIP variants</span></b-checkbox>
				<b-tooltip target="show-svip-vars" placement="top">show only variants for which SVIP-specific data exists</b-tooltip>
			</div>
		</div>

		<div class="variant-results">
			<b-table
				:fields="fields" :items="makeVariantProvider(this.metaUpdated)" api-url="variants" :sort-by="sortBy" :filter="packedFilter"
				:current-page="currentPage" :per-page="perPage"
			>
				<template slot="in_svip" slot-scope="data">
					<img src="../../assets/svip_small_icon.png" style="width: 22px" v-if="data.item.in_svip" alt="In SVIP" />
				</template>

				<template slot="hgvs_c" slot-scope="data">
					<inline-coordinates :val="data.value" />
				</template>

				<template slot="hgvs_p" slot-scope="data">
					<inline-coordinates :val="data.value" />
				</template>

				<!--
				<template slot="hgvs_g" slot-scope="data" v-if="data.value">
					<span class="text-muted">{{ data.item.reference_name }}:</span>{{ data.value }}
				</template>
				-->

				<template slot="hgvs_g" slot-scope="data">
					<inline-coordinates :val="data.value" />
				</template>


				<template slot="action" slot-scope="data">
					<b-button size="sm" :to="{name: 'variant', params: { gene_id: $route.params.gene_id, variant_id: data.item.id}}">Show Details</b-button>
				</template>
			</b-table>

			<b-pagination v-if="totalRows > perPage" v-model="currentPage" :total-rows="totalRows" :per-page="perPage" />
		</div>
	</div>

</template>

<script>
import {mapGetters} from "vuex";
import store from "@/store";
import {makeVariantProvider} from '@/components/genes/item_providers/variant_provider';
import {change_from_hgvs, var_to_position, desnakify} from "@/utils";

export default {
	data() {
		return {
			currentFilter: {
				search: '',
				in_svip: store.state.genes.showOnlySVIP,
				gene: this.$route.params.gene_id
			},
			currentPage: 1,
			perPage: 20,
			totalRows: 0,
			confirmDeletion: false,
			fields: [
				{
					key: "in_svip",
					label: "",
					sortable: false,
					thStyle: 'width: 22px;'
				},
				{
					key: "name",
					label: "Name",
					sortable: true
				},
				{
					key: "hgvs_c",
					label: "HGVS coding",
					formatter: x => change_from_hgvs(x, true),
					sortable: true
				},
				{
					key: "hgvs_p",
					label: "HGVS protein",
					formatter: x => change_from_hgvs(x, true),
					sortable: true
				},
				/*
				{
					key: "hgvs_g",
					label: "Position",
					formatter: (x, k, variant) => var_to_position(variant),
					sortable: true
				},
				*/
				{
					key: "hgvs_g",
					label: "HGVS genomic",
					formatter: x => change_from_hgvs(x, true),
					sortable: true
				},
				/*
				{
					key: "sources",
					label: "Sources",
					formatter: x => x.join(", "),
					sortable: true
				},
				{
					key: "so_name",
					label: "Molecular Consequence",
					sortable: true,
					formatter: x => desnakify(x)
				},
				*/
				/*
        {
            key: 'svip_data.tier_level',
            label: 'Tier Level',
            sortable: true
        },
        {
            key: 'svip_data.SVIP_status',
            label: 'Status',
            sortable: true
        },
        {
            key: 'svip_data.SVIP_confidence_score',
            label: 'Score',
            sortable: true
        },
        */
				{
					key: "action",
					label: "",
					sortable: false
				},

			],
			sortBy: null
		};
	},
	computed: {
		...mapGetters({
			gene: "currentGene",
			variants: "variants",
			geneVariants: "geneVariants"
		}),
		showOnlySVIP: {
			get() {
				return store.state.genes.showOnlySVIP;
			},
			set(value) {
				this.currentFilter.in_svip = value;
				store.dispatch("toggleShowSVIP", {showOnlySVIP: value});
			}
		},
		synonyms() {
			return this.gene.aliases ? this.gene.aliases.join(", ") : "";
		},
		packedFilter() {
			return JSON.stringify(this.currentFilter);
		}
	},
	methods: {
		metaUpdated({ count }) {
			this.totalRows = count;
		},
		makeVariantProvider
	},
	beforeRouteEnter(to, from, next) {
		if (to.params.gene_id !== "new") {
			// ask the store to get 1) the gene data, and 2) all the variants for this gene (for now)
			store.dispatch('getGene', { gene_id: to.params.gene_id }).then(() => {
				next();
			});
		}
	},
	created() {
		this.currentFilter.gene = this.$route.params.gene_id;
	}
};
</script>

<style scoped>
.gene-summary {
	margin-bottom: 16px;
}

.gene-info-items {
	margin: 5px;
}
.gene-info-items td {
	padding: 3px;
}
.gene-info-items td.row-label {
	font-weight: bold;
}
</style>
