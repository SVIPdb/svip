<template>
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
            <b-card-body>
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
                    <b-form-input
                      v-model="reference"
                      required
                      placeholder="Type reference"
                      class="rounded-0"
                    ></b-form-input>
                  </b-col>
                  <b-col cols="2">
                    <b-button
                      :disabled="source == null || reference == null"
                      type="submit"
                      block
                      class="custom-border-right"
                      variant="success"
                      @click="addEvidence"
                      target="_blank"
                    >
                      <icon name="plus"></icon>
                    </b-button>
                  </b-col>
                </b-row>
              </b-container>
            </b-card-body>
          </b-tab>
          <b-tab title="Use text mining tool">
            <b-card-body>
              <b-table
                show-empty
                :busy="variomes.length == 0"
                :items="variomes.publications"
                :sort-by="sortBy"
                :sort-desc="sortDesc"
                :fields="fieldsTextMining"
              >
                <div slot="table-busy" class="text-center text-danger my-2">
                  <b-spinner class="align-middle"></b-spinner>
                  <strong>Loading...</strong>
                </div>
                <template v-slot:cell(id)="data">
                  <b-link @click="addEvidenceFromList(data.value)" target="_blank">{{ data.value }}</b-link>
                </template>
                <template v-slot:cell(score)="data">{{ data.value.toFixed(2) }}</template>
              </b-table>
            </b-card-body>
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
import fields from "@/data/curation/summary/fields.json";
import fieldsTextMining from "@/data/curation/text_mining/fields.json";
import store from "@/store";
import { change_from_hgvs, desnakify, var_to_position } from "@/utils";
import { HTTP } from "@/router/http";

export default {
	name: "AnnotateVariant",
	components: {
		variantInformations,
		evidenceCard
	},
	data() {
		return {
			fields,
			fieldsTextMining,
			source: "PMID",
			reference: null,
			variomes: [],
			totalRows: 1,
			sortBy: "score",
			sortDesc: true
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
			let route = this.$router.resolve({
				name: "add-evidence",
				params: {
					gene_id: this.$route.params.gene_id,
					variant_id: this.$route.params.variant_id,
					disease_id: this.$route.params.disease_id
				},
				query: { source: this.source, reference: this.reference }
			});
			window.open(route.href, "_blank");
		},
		addEvidenceFromList(id) {
			this.reference = id;
			return this.addEvidence();
		}
	},
	created() {
		HTTP.get(`variomes_search`, {
			params: {
				gene: this.variant.gene.symbol,
				variant: this.variant.name,
				disease: this.variant.svip_data.diseases.find(
					element => element.id == this.$route.params.disease_id
				).name
			}
		})
			.then(response => {
				this.variomes = response.data;
			})
			.catch(err => {
				this.variomes = {
					error: "Couldn't retrieve publication info, try again later."
				};
			});
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
