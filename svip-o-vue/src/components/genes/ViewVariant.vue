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

	<div class="container-fluid">
		<div class="card">
			<div class="card-body">
				<table class="table">
					<tr>
						<th>Gene Name</th>
						<th>Variant</th>
						<th>Variant HGVS.c</th>
						<th>Variant HGVS.p</th>
						<th>dbSNP</th>
						<th>Molecular consequence</th>
						<th>Position</th>
						<th>Ref. Genome</th>
					</tr>
					<tr>
						<td>
							<b>
								<router-link :to="'/gene/' + gene_id">{{ variant.gene.symbol }}</router-link>
							</b>
						</td>
						<td>
							<b>{{ variant.name }}</b>
						</td>

						<coordinates :val="hgvs_c_pos"/>
						<coordinates :val="hgvs_p_pos"/>

						<optional :val="variant.dbsnp_ids">
							<a v-for="rsid in variant.dbsnp_ids" :key="rsid" :href=" 'https://www.ncbi.nlm.nih.gov/snp/' + rsid" target="_blank">
								rs{{ rsid }}
								<icon name="external-link-alt"></icon>
							</a>
						</optional>

						<td>{{ desnakify(variant.so_name) }}</td>

						<optional :val="var_position">
							<span class="text-muted">{{ variant.reference_name }}:</span>&#x200b;{{ var_position }}
						</optional>

						<td>{{ variant.reference_name }}</td>
					</tr>
				</table>
			</div>
		</div>

		<variant-svip v-if="variant.svip_data" :variant="variant"></variant-svip>
		<variant-public-databases :variant="variant"></variant-public-databases>

		<VariantExternalInfo :mvInfo="variant.mv_info"/>
		<VariantExternalInfo :mvInfo="variant.mv_info" :extras="all_extras" />
	</div>
</template>

<script>
// import geneVariants from '@/components/Variants'
import {mapGetters} from "vuex";
import variantPublicDatabases from "@/components/genes/variantPublicDatabases";
import variantSvip from "@/components/genes/variantSvip";
import store from "@/store";

import {change_from_hgvs, desnakify, var_to_position} from "@/utils";
import VariantExternalInfo from "@/components/genes/external/VariantExternalInfo";

export default {
	name: "ViewVariant",
	components: {VariantExternalInfo, variantPublicDatabases, variantSvip},
	computed: {
		...mapGetters({
			variant: "variant",
			gene: "gene"
		}),
		synonyms() {
			if (this.gene.geneAliases === undefined) return "";
			return this.gene.geneAliases.join(", ");
		},
		gene_id() {
			let test = this.variant.gene.url.match(/genes\/(\d+)/);
			if (test) return test[1];
			return "";
		},
		hgvs_c_pos() {
			return change_from_hgvs(this.variant.hgvs_c, true);
		},
		hgvs_p_pos() {
			return change_from_hgvs(this.variant.hgvs_p, true);
		},
		var_position() {
			return var_to_position(this.variant);
		},
		hg19_id() {
			return var_to_position(this.variant, true);
		},
		all_extras() {
			return this.variant.variantinsource_set.reduce((acc, x) => {
				return Object.assign({}, acc, x['extras']);
			}, {});
		}
	},
	// components: {geneVariants: geneVariants},
	methods: {
		desnakify
	},
	beforeRouteEnter(to, from, next) {
		const { variant_id } =  to.params;

		// ask the store to populate detailed information about this variant
		store.dispatch('getGeneVariant', { variant_id: variant_id }).then(() => {
			next();
		})
	}
};
</script>

<style scoped>
.container,
.container-fluid {
	margin-top: 20px;
}
</style>
