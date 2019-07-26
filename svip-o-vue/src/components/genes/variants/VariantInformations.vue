<template>
  <b-card class="shadow-sm mb-3" align="left" no-body>
    <b-card-body class="p-0">
      <b-table
        class="mb-0"
        :items="[variant]"
        :fields="fields"
        show-empty
        empty-text="There seems to be an error"
      >
        <template slot="gene" slot-scope="row">
          <router-link
            class="font-weight-bold"
            :to="{ name: 'gene', params: { gene_id: row.item.id }}"
          >{{ row.item.gene.symbol }}</router-link>
        </template>
        <template slot="name" slot-scope="data">
          <b>{{ data.value }}</b>
        </template>
        <template slot="hgvs_c" slot-scope="data">
          <p class="mb-0">
            <span class="text-muted">{{ data.value.split(":")[0] }}:</span>
            {{ data.value.split(":")[1] }}
          </p>
        </template>
        <template slot="hgvs_p" slot-scope="data">
          <p class="mb-0">
            <span class="text-muted">{{ data.value.split(":")[0] }}:</span>
            {{ data.value.split(":")[1] }}
          </p>
        </template>
        <template slot="hgvs_g" slot-scope="data">
          <p class="mb-0">
            <span class="text-muted">{{ data.value.split(":")[0] }}:</span>
            {{ data.value.split(":")[1] }}
          </p>
        </template>
        <template slot="dbsnp_ids" slot-scope="data">
          <a
            v-for="rsid in data.value"
            :key="rsid"
            :href=" 'https://www.ncbi.nlm.nih.gov/snp/' + rsid"
            target="_blank"
          >
            rs{{ rsid }}
            <icon name="external-link-alt"></icon>
          </a>
        </template>
        <template slot="position" slot-scope="row">
          <p class="mb-0">
            <span class="text-muted transcript-id">{{ row.item.reference_name }}:</span>
            {{ var_position }}
          </p>
        </template>
        <template slot="frequency">
          <span v-if="allele_frequency">{{ allele_frequency }}</span>
          <span v-else class="unavailable">unavailable</span>
        </template>
      </b-table>
    </b-card-body>
  </b-card>
</template>

<script>
import { change_from_hgvs, desnakify, var_to_position } from "@/utils";

export default {
  name: "VariantInformations",
  props: ["variant", "fields"],
  data() {
    return {
      showCurationTool: false
    };
  },
  computed: {
    allele_frequency() {
      if (this.variant.mv_info) {
        if (this.variant.mv_info.gnomad_genome) {
          return `gnomAD: ${round(
            this.variant.mv_info.gnomad_genome.af.af * 100.0,
            4
          )}%`;
        } else if (this.variant.mv_info.exac) {
          return `ExAC: ${round(this.variant.mv_info.exac.af * 100.0, 4)}%`;
        }
      }

      return null;
    },
    var_position() {
      return var_to_position(this.variant);
    }
  }
};
</script>

<style>
</style>
