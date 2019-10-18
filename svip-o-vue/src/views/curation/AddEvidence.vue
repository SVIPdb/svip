<template>
  <b-container fluid>
    <variant-informations :variant="variant" :fields="fields" />
    <b-row>
      <b-col sm="9">
        <b-card no-body>
          <b-card-body>
            <b-container
              fluid
              class="evidence"
              v-if="variomes && !variomes.error"
              style="max-height:20rem;overflow-y:scroll;"
              @mouseup="getSelectionText()"
              @contextmenu.prevent.stop="handleRightClick($event)"
            >
              <h5 class="font-weight-bolder" v-html="variomes.publication.title_highlight"></h5>
              <span>{{variomes.publication.date}}</span>
              <br />
              <p>
                <b-link
                  :href="`https://www.ncbi.nlm.nih.gov/pubmed/?term=${author}[Author]`"
                  target="_blank"
                  v-for="(author,index) in variomes.publication.authors"
                  :key="index"
                >{{author + (index < variomes.publication.authors.length-1 ? ', ' : '')}}</b-link>
              </p>
              <b>Abstract</b>
              <p class="text-justify" v-html="variomes.publication.abstract_highlight"></p>
              <small>
                PMID:
                <b-link
                  :href="`https://www.ncbi.nlm.nih.gov/pubmed/${variomes.publication.id}`"
                  target="_blank"
                >{{variomes.publication.id}}</b-link>
              </small>
            </b-container>
            <div
              v-else-if="variomes && variomes.error"
              class="text-center"
            >We couldn't load the abstract due to some techincal issues.</div>
            <div v-else class="text-center">
              <b-spinner label="Spinning" variant="primary"></b-spinner>Loading
            </div>
          </b-card-body>
        </b-card>
        <br />
        <b-card no-body>
          <b-card-body>
            <b-container fluid>
              <b-form @submit.prevent>
                {{form.variants}}
                <b-form-group
                  label-cols-sm="4"
                  label-cols-lg="3"
                  label="Add variants ? (In case of a combination)"
                  label-for="variants-combination"
                >
                  <SearchBar
                    id="variants-combination"
                    variants-only
                    multiple
                    v-model="form.variants"
                  />
                </b-form-group>
                <b-form-group
                  label-cols-sm="4"
                  label-cols-lg="3"
                  label="For which type of evidence ?"
                  label-for="evidence"
                >
                  <b-form-select
                    id="evidence"
                    :required="required"
                    v-model="type_of_evidence"
                    @input="setEvidence()"
                  >
                    <optgroup
                      v-for="(label,index) in Object.keys(inputs)"
                      :key="index"
                      :label="label"
                    >
                      <option
                        v-for="(option,n) in Object.keys(inputs[label])"
                        :key="n"
                        :value="{label: label,value: option}"
                      >{{ option }}</option>
                    </optgroup>
                  </b-form-select>
                </b-form-group>

                <b-form-group
                  label-cols-sm="4"
                  label-cols-lg="3"
                  label="Effect of the variant on the therapy"
                  label-for="effect"
                >
                  <b-form-select
                    id="effect"
                    v-model="form.effect"
                    :options="effects"
                    :required="required"
                  ></b-form-select>
                </b-form-group>

                <b-form-group
                  label-cols-sm="4"
                  label-cols-lg="3"
                  label="Select a Tier criteria"
                  label-for="tier_criteria"
                >
                  <b-form-select
                    id="tier_criteria"
                    v-model="form.tier_criteria"
                    :options="tier_criteria"
                    :required="required"
                  ></b-form-select>
                </b-form-group>

                <b-form-group
                  label-cols-sm="4"
                  label-cols-lg="3"
                  label="Origin of the mutation"
                  label-for="origin"
                >
                  <b-form-select
                    id="origin"
                    v-model="form.origin"
                    :options="['Somatic', 'Germline', 'Both somatic and germline', 'Unknown']"
                    :required="required"
                  ></b-form-select>
                </b-form-group>

                <b-form-group
                  label-cols-sm="4"
                  label-cols-lg="3"
                  label="Support"
                  label-for="support"
                >
                  <b-form-select
                    id="support"
                    v-model="form.support"
                    :options="['Strong', 'Moderate', 'Low', 'Other']"
                    :required="required"
                  ></b-form-select>
                </b-form-group>

                <b-form-group
                  label-cols-sm="4"
                  label-cols-lg="3"
                  label="Complementary information (viewed by others)"
                  label-for="information"
                >
                  <b-form-textarea
                    id="information"
                    v-model="form.information"
                    rows="3"
                    max-rows="5"
                    :required="required"
                  ></b-form-textarea>
                </b-form-group>

                <b-form-group
                  label-cols-sm="4"
                  label-cols-lg="3"
                  label="Personal comment (viewed by you only)"
                  label-for="note"
                >
                  <b-form-textarea
                    id="note"
                    v-model="form.note"
                    rows="3"
                    max-rows="5"
                    :required="required"
                  ></b-form-textarea>
                </b-form-group>
                <b-form-group
                  label-cols-sm="4"
                  label-cols-lg="3"
                  label="Your annotations"
                  label-for="annotations"
                >
                  <b-input-group
                    v-for="(annotation,index) in form.annotations"
                    :key="index"
                    class="mt-3"
                  >
                    <b-form-textarea rows="3" disabled :value="annotation" no-resize></b-form-textarea>
                    <b-input-group-append>
                      <b-button variant="danger" @click="removeAnnotation(index)">
                        <icon name="minus"></icon>
                      </b-button>
                    </b-input-group-append>
                  </b-input-group>
                </b-form-group>
              </b-form>
            </b-container>
          </b-card-body>
        </b-card>
      </b-col>

      <b-col sm="3">
        <b-button
          variant="outline-success"
          size="lg"
          block
          class="shadow-sm mb-3"
          :href="currentUrl"
          target="_blank"
        >Duplicate</b-button>
        <b-card class="shadow-sm mb-3" header-bg-variant="white" no-body>
          <h5 slot="header" class="d-flex align-items-center">
            Actions
            <b-link
              class="ml-auto"
              :aria-expanded="showAction ? 'true' : 'false'"
              aria-controls="action"
              @click="showAction = !showAction"
            >
              <icon :name="showAction ? 'chevron-down' : 'chevron-right'"></icon>
            </b-link>
          </h5>
          <b-card-body class="p-0 m-0">
            <b-collapse id="action" v-model="showAction" class="m-3">
              <br />
              <icon class="mr-1" name="newspaper"></icon>PMID:
              <b-link
                v-if="variomes"
                :href="`https://www.ncbi.nlm.nih.gov/pubmed/${variomes.publication.id}`"
                target="_blank"
              >{{variomes.publication.id}}</b-link>
              <br />
              <icon class="mr-1" name="key"></icon>Status:
              <b>Draft</b>
              <br />
              <icon class="mr-1" name="user"></icon>Creator:
              <b>Curator 1</b>
              <br />
              <icon class="mr-1" name="calendar"></icon>Last modification:
              <b>2019-08-27</b>
              <br />
              <br />
              <div class="d-flex align-items-center">
                <b-link class="text-danger">
                  <icon class="mr-1" name="trash"></icon>Delete
                </b-link>
                <b-button class="ml-auto" variant="outline-success">Save Draft</b-button>
              </div>
              <b-button class="mt-3" block variant="success" @click="onSubmit">Save evidence</b-button>
            </b-collapse>
          </b-card-body>
        </b-card>
        <b-card class="shadow-sm" header-bg-variant="white" no-body>
          <h5 slot="header" class="d-flex align-items-center">
            Keywords
            <b-link
              class="ml-auto"
              :aria-expanded="showStat ? 'true' : 'false'"
              aria-controls="statistic"
              @click="showStat = !showStat"
            >
              <icon :name="showStat ? 'chevron-down' : 'chevron-right'"></icon>
            </b-link>
          </h5>
          <b-card-body class="p-0 m-0">
            <b-collapse id="statistic" v-model="showStat" class="m-3">
              <div v-if="variomes">
                <b-link
                  :href="`https://www.ncbi.nlm.nih.gov/pubmed/?term=${variomes.query.gene}[Title/Abstract]`"
                  target="_blank"
                >
                  <b-badge
                    class="bg-gene"
                  >{{variomes.query.gene}} ({{variomes.publication.details.query_details.targetGeneCount}})</b-badge>
                </b-link>
                <b-link
                  :href="`https://www.ncbi.nlm.nih.gov/pubmed/?term=${variomes.query.variant}[Title/Abstract]`"
                  target="_blank"
                >
                  <b-badge
                    class="bg-variant"
                  >{{variomes.query.variant}} ({{variomes.publication.details.query_details.targetVariantCount}})</b-badge>
                </b-link>
                <b-link
                  :href="`https://www.ncbi.nlm.nih.gov/pubmed/?term=${variomes.query.disease}[Title/Abstract]`"
                  target="_blank"
                >
                  <b-badge
                    class="bg-disease"
                  >{{variomes.query.disease}} ({{variomes.publication.details.query_details.targetDiseaseCount}})</b-badge>
                </b-link>
                <b-link
                  :href="`https://www.ncbi.nlm.nih.gov/pubmed/?term=${variomes.query.gene}[Title/Abstract] AND ${variomes.query.variant}[Title/Abstract] AND ${variomes.query.disease}[Title/Abstract]`"
                  target="_blank"
                >
                  <b-badge
                    class="bg-primary"
                  >{{variomes.query.gene}} + {{variomes.query.variant}} + {{variomes.query.disease}}</b-badge>
                </b-link>
                <b-link
                  :href="`https://www.ncbi.nlm.nih.gov/pubmed/?term=${variomes.query.gene}[Title/Abstract] AND ${variomes.query.variant}[Title/Abstract]`"
                  target="_blank"
                >
                  <b-badge class="bg-info">{{variomes.query.gene}} + {{variomes.query.variant}}</b-badge>
                </b-link>
              </div>
              <div v-else class="text-center">
                <b-spinner label="Spinning" variant="primary"></b-spinner>Loading
              </div>
            </b-collapse>
          </b-card-body>
        </b-card>
      </b-col>
    </b-row>
    <vue-simple-context-menu
      :elementId="'annotationMenu'"
      :options="options"
      :ref="'vueSimpleContextMenu'"
      @option-clicked="optionClicked"
    ></vue-simple-context-menu>
  </b-container>
</template>
<script>
import { mapGetters } from "vuex";
import variantInformations from "@/components/curation/widgets/VariantInformations";

import fields from "@/data/curation/summary/fields.json";
import inputs from "@/data/curation/evidence/options.json";
import store from "@/store";
import { HTTP } from "@/router/http";
import SearchBar from "@/components/widgets/SearchBar";

export default {
  name: "AddEvidence",
  components: {
    SearchBar,
    variantInformations
  },
  data() {
    return {
      fields,
      inputs,
      options: [
        {
          name: "Add textual evidence",
          slug: "annotate"
        },
        {
          name: "Copy selection",
          slug: "copy"
        }
      ],
      required: true,
      selection: "",
      showAction: true,
      showStat: true,
      variomes: null,
      type_of_evidence: {
        value: null,
        label: null
      },
      filterLabel: null,
      variants: [],
      form: {
        variants: [],
        evidence: null,
        effect: null,
        tier_criteria: null,
        origin: null,
        support: null,
        comment: null,
        note: null,
        annotations: []
      }
    };
  },
  methods: {
    test() {
      console.log("test");
    },
    getSelectionText() {
      if (window.getSelection) {
        this.selection = window.getSelection().toString();
      } else {
        this.selection = "";
      }
    },
    handleRightClick(event) {
      if (this.selection.length > 0) {
        this.$refs.vueSimpleContextMenu.showMenu(event);
      }
    },
    optionClicked(event) {
      if (event.option.slug == "copy") {
        this.doCopy();
      } else if (event.option.slug == "annotate") {
        this.form.annotations.push(this.selection);
      }
    },
    doCopy() {
      this.$copyText(this.selection).then(
        function(e) {
          alert("Copied");
        },
        function(e) {
          alert("Can not copy");
        }
      );
    },
    removeAnnotation(index) {
      this.form.annotations.splice(index, 1);
    },
    onSubmit() {
      this.required = !this.required;
    },
    setEvidence() {
      this.form.evidence = this.type_of_evidence.value;
      this.filterLabel = this.type_of_evidence.label;
    },
    noResponse() {
      // FIXME: what is this supposed to do? the return value of setTimeout isn't used
      setTimeout(function() {
        return this.variomes == null ? true : false;
      }, 1000);
    }
  },
  computed: {
    ...mapGetters({
      variant: "variant"
    }),
    currentUrl() {
      return window.location.href;
    },
    effects() {
      return this.form.evidence != null
        ? Object.keys(this.inputs[this.filterLabel][this.form.evidence])
        : [];
    },
    tier_criteria() {
      return this.form.evidence != null && this.form.effect != null
        ? this.inputs[this.filterLabel][this.form.evidence][this.form.effect]
        : [];
    }
  },
  created() {
    HTTP.get(`variomes_single_ref`, {
      params: {
        id: this.$route.query.reference,
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
.gene {
  color: #e3639f;
  font-weight: bold;
}
.variant {
  color: #4b7bef;
  font-weight: bold;
}
.disease {
  color: #3d811e;
  font-weight: bold;
}
.bg-gene {
  background-color: #e3639f !important;
}
.bg-variant {
  background-color: #4b7bef !important;
}
.bg-disease {
  background-color: #3d811e !important;
}
.evidence ::-moz-selection {
  /* Code for Firefox */
  color: white;
  background: #2c3e50;
}

.evidence ::selection {
  color: white;
  background: #2c3e50;
}
</style>
