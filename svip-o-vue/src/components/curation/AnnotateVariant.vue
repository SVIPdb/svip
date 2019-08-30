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
    <evidence-card :items="evidences" />
    <div>
      <b-card no-body>
        <b-tabs
          card
          justified
          nav-wrapper-class="bg-primary"
          nav-class="text-white"
          active-nav-item-class="font-weight-bolder"
        >
          <b-tab title="Enter your reference" active>
            <b-card-text>
              <b-container>
                <b-row no-gutters>
                  <b-col cols="5">
                    <b-form-select
                      required
                      class="custom-border-left"
                      v-model="source"
                      :options="['PMID']"
                    ></b-form-select>
                  </b-col>
                  <b-col cols="5">
                    <b-form-input v-model="reference" required placeholder="Type reference"></b-form-input>
                    <!-- <v-select
                      class="custom-style"
                      :options="['3213123']"
                      v-model="reference"
                      taggable
                    >
                      <template #search="{attributes, events}">
                        <input
                          class="vs__search"
                          :required="!reference"
                          v-bind="attributes"
                          v-on="events"
                        />
                      </template>
                    </v-select>-->
                  </b-col>
                  <b-col cols="2">
                    <b-button
                      :disabled="source == null || reference == null"
                      type="submit"
                      block
                      class="custom-border-right"
                      variant="success"
                      @click="addEvidence"
                    >
                      <icon name="plus"></icon>
                    </b-button>
                  </b-col>
                </b-row>
              </b-container>
            </b-card-text>
          </b-tab>
          <b-tab title="Use text mining tool">
            <b-card-text>Tab Contents 2</b-card-text>
          </b-tab>
          <b-tab title="Use prediction tools">
            <b-card-text>Tab Contents 3</b-card-text>
          </b-tab>
        </b-tabs>
      </b-card>
    </div>
  </div>
</template>
<script>
import { mapGetters } from "vuex";
import variantInformations from "@/components/curation/widgets/VariantInformations";
import evidenceCard from "@/components/curation/widgets/EvidenceCard";
import fields from "@/components/curation/data/summary/fields.json";
import store from "@/store";
import { change_from_hgvs, desnakify, var_to_position } from "@/utils";

export default {
  name: "AnnotateVariant",
  components: {
    variantInformations,
    evidenceCard
  },
  data() {
    return {
      fields,
      source: "PMID",
      reference: null
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
    },
    evidences() {
      return this.variant.svip_data.diseases.find(
        element => element.id == this.$route.params.disease_id
      ).curation_entries;
    }
  },
  // components: {geneVariants: geneVariants},
  methods: {
    desnakify,
    addEvidence() {
      this.$router.push({
        name: "add-evidence",
        params: {
          gene_id: this.$route.params.gene_id,
          variant_id: this.$route.params.variant_id,
          disease_id: this.$route.params.disease_id
        },
        query: { source: this.source, reference: this.reference }
      });
    }
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

<style>
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

.custom-style .dropdown-toggle {
  border-radius: 0 !important;
  height: calc(2.15625rem + 2px) !important;
}

.custom-border-left {
  border-radius: 0.25rem 0 0 0.25rem !important;
}

.custom-border-right {
  border-radius: 0 0.25rem 0.25rem 0 !important;
}
</style>
