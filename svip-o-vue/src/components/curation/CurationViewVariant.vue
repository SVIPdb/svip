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
    <variant-informations :variant="variant" :fields="fields" />
    <variant-svip v-if="variant.svip_data" :variant="variant" :gene="Number(gene_id)"></variant-svip>

    <b-row>
      <b-col>
        <variant-public-databases :variant="variant"></variant-public-databases>
      </b-col>
    </b-row>

    <VariantExternalInfo :mvInfo="variant.mv_info" :variant="variant" :extras="all_extras" />

    <b-row>
      <b-col>
        <b-card class="shadow-sm mt-3" align="left" no-body>
          <b-card-body class="p-0 text-center">
            <b-row no-gutters>
              <b-col v-for="(item,index) in linkItems" :key="index">
                <b-button squared block variant="outline-secondary" :href="item.link" target="_blank">
                  {{ item.source }}
                  <icon name="external-link-alt"></icon>
                </b-button>
              </b-col>
            </b-row>
          </b-card-body>
        </b-card>
      </b-col>
    </b-row>
  </div>
</template>

<script>
// import geneVariants from '@/components/Variants'
import round from "lodash/round";
import { mapGetters } from "vuex";
import variantPublicDatabases from "@/components/genes/variants/PublicDatabases";
import variantSvip from "@/components/curation/SVIPCuration";
import variantInformations from "@/components/genes/variants/VariantInformations";
import store from "@/store";

import fields from "./ViewVariant/fields.json";
import linkFields from "./ViewVariant/links/fields.json";
import linkItems from "./ViewVariant/links/items.json";

import { change_from_hgvs, desnakify, var_to_position } from "@/utils";
import VariantExternalInfo from "@/components/genes/variants/external/VariantExternalInfo";

export default {
  name: "CurationViewVariant",
  components: {
    VariantExternalInfo,
    variantPublicDatabases,
    variantSvip,
    "variant-informations": variantInformations
  },
  data() {
    return {
      showAliases: false,
      showCurationTool: false,
      fields,
      linkFields,
      linkItems
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
