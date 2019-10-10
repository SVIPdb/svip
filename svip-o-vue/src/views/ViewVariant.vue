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
    <div class="card variant-card">
      <div class="card-body top-level">
        <table class="table variant-header">
          <tr>
            <th>Gene Name</th>
            <th>Variant</th>
            <th>HGVS.c</th>
            <th>HGVS.p</th>
            <th>HGVS.g</th>
            <th>dbSNP</th>
            <!-- <th>Molecular consequence</th> -->
            <th>Position</th>
            <th>Allele Frequency</th>
            <th></th>
            <!--- for actions -->
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

            <coordinates :val="hgvs_c_pos" />
            <coordinates :val="hgvs_p_pos" />
            <coordinates :val="hgvs_g_pos" />

            <optional :val="variant.dbsnp_ids">
              <a
                v-for="rsid in variant.dbsnp_ids"
                :key="rsid"
                :href=" 'https://www.ncbi.nlm.nih.gov/snp/' + rsid"
                target="_blank"
              >
                rs{{ rsid }}
                <icon name="external-link-alt"></icon>
              </a>
            </optional>

            <!-- <td>{{ desnakify(variant.so_name) }}</td> -->

            <optional :val="var_position">
              <span class="text-muted transcript-id">{{ variant.reference_name }}:</span>
              &#x200b;{{ var_position }}
            </optional>

            <td>
              <span v-if="allele_frequency">{{ allele_frequency }}</span>
              <span v-else class="unavailable">unavailable</span>
            </td>

            <td>
              <div class="details-tray" style="text-align: right;">
                <b-button
                  size="sm"
                  @click.stop="() => { showAliases = !showAliases; }"
                >{{ showAliases ? "Hide" : "Show" }} Aliases</b-button>
              </div>
            </td>
          </tr>

          <transition name="slide-fade">
            <tr v-if="showAliases" class="details-row">
              <td colspan="9">
                <div class="aliases-list">
                  <div v-for="(x) in variant.gene.aliases" :key="x">{{ x }}</div>
                </div>
              </td>
            </tr>
          </transition>
        </table>
      </div>
    </div>

    <variant-svip v-if="variant.svip_data" :variant="variant" :gene="gene_id"></variant-svip>
    <variant-public-databases :variant="variant"></variant-public-databases>

    <VariantExternalInfo :variant="variant" :mvInfo="variant.mv_info" :extras="all_extras" />
  </div>
</template>

<script>
// import geneVariants from '@/components/Variants'
import round from "lodash/round";
import { mapGetters } from "vuex";
import variantPublicDatabases from "@/components/genes/variants/PublicDatabases";
import variantSvip from "@/components/genes/variants/SVIPInfo";
import store from "@/store";

import { change_from_hgvs, desnakify, var_to_position } from "@/utils";
import VariantExternalInfo from "@/components/genes/variants/external/VariantExternalInfo";

export default {
  name: "ViewVariant",
  components: { VariantExternalInfo, variantPublicDatabases, variantSvip },
  data() {
    return {
      showAliases: false
    };
  },
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
    hgvs_g_pos() {
      return change_from_hgvs(this.variant.hgvs_g, true);
    },
    var_position() {
      return var_to_position(this.variant);
    },
    hg19_id() {
      return var_to_position(this.variant, true);
    },
    all_extras() {
      return this.variant.variantinsource_set.reduce((acc, x) => {
        return Object.assign({}, acc, x["extras"]);
      }, {});
    },
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
    }
  },
  // components: {geneVariants: geneVariants},
  methods: {
    desnakify
  },
  beforeRouteEnter(to, from, next) {
    const { variant_id } = to.params;

    // ask the store to populate detailed information about this variant
    store.dispatch("getGeneVariant", { variant_id: variant_id }).then(() => {
      next();
    });
  }
};
</script>

<style scoped>
.variant-card .card-body {
  padding: 0;
}
.variant-header {
  margin-bottom: 0;
}

.variant-header td,
.variant-header th {
  vertical-align: text-bottom;
  padding: 1rem;
}
.aliases-list {
  font-style: italic;
}

.details-row {
  background: #eee;
  box-shadow: inset;
}

/* Enter and leave animations can use different */
/* durations and timing functions.              */
.slide-fade-enter-active {
  transition: all 0.5s ease;
}
.slide-fade-leave-active {
  transition: all 0.3s ease;
}
.slide-fade-enter-to,
.slide-fade-leave {
  max-height: 120px;
}
.slide-fade-enter, .slide-fade-leave-to
	/* .slide-fade-leave-active below version 2.1.8 */ {
  opacity: 0;
  max-height: 0;
}
</style>
