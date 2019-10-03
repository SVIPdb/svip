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
    <b-row>
      <!-- Variant Information Box (Full-width) -->
      <b-col>
        <variant-informations
          :variant="variant"
          :fields="fields"
          tbodyClass="small"
          theadClass="small"
        />
      </b-col>
    </b-row>

    <b-row>
      <!-- Curation Tool Box (3/12) -->
      <b-col md="3">
        <b-card
          no-body
          header="Curation tool"
          header-bg-variant="primary"
          header-text-variant="white"
        >
          <b-list-group flush>
            <b-list-group-item
              @click.prevent="selected = selected == 1 ? null : 1"
              href="#"
              :class="selected == 1 ? 'bg-light' : ''"
            >
              Known reference
              <transition name="slide-fade">
                <icon v-if="selected == 1" name="arrow-circle-right"></icon>
              </transition>
            </b-list-group-item>
            <b-list-group-item
              @click.prevent="selected = selected == 2 ? null : 2"
              href="#"
              :class="selected == 2 ? 'bg-light' : ''"
            >
              Literature search
              <transition name="slide-fade">
                <icon v-if="selected == 2" name="arrow-circle-right"></icon>
              </transition>
            </b-list-group-item>
            <b-list-group-item
              @click.prevent="selected = selected == 3 ? null : 3"
              href="#"
              :class="selected == 3 ? 'bg-light' : ''"
            >
              Prediction tools
              <transition name="slide-fade">
                <icon v-if="selected == 3" name="arrow-circle-right"></icon>
              </transition>
            </b-list-group-item>
          </b-list-group>
        </b-card>
      </b-col>

      <b-col md="9">
        <!-- MISSING SUMMARY TABLE -->

        <!-- Form Known Reference (9/12) -->
        <transition name="slide-fade">
          <b-card
            v-if="selected==1"
            header="Enter a reference"
            header-bg-variant="primary"
            header-text-variant="white"
          >
            <b-container fluid>
              <b-row no-gutters>
                <b-col cols="5">
                  <b-form-select class="custom-border-left" v-model="source" :options="options"></b-form-select>
                </b-col>
                <b-col cols="5">
                  <v-select class="custom-style" :options="['Canada', 'United States']"></v-select>
                </b-col>
                <b-col cols="2">
                  <b-button
                    block
                    class="custom-border-right"
                    variant="success"
                    @click="checkEntry()"
                  >
                    <icon name="plus"></icon>
                  </b-button>
                </b-col>
              </b-row>

              <h5 v-show="checkItems.length > 0">Check your reference</h5>
              <b-table
                v-show="checkItems.length > 0"
                :fields="['reference','title','authors','actions']"
                :items="checkItems"
              >
                <template slot="actions" slot-scope="row">
                  <icon class="text-success mr-1" name="check"></icon>
                  <icon class="text-danger mr-1" name="times"></icon>
                </template>
              </b-table>

              <h5>Curations added</h5>
              <b-table
                :fields="['reference','present_in_svip_data','list_of_variants','action']"
                :items="reference == '' ? [] : items"
                :filter="reference"
                show-empty
                empty-text="There are no references to show"
                empty-filtered-text="There are no references matching your request"
              >
                <template slot="present_in_svip_data" slot-scope="data">
                  <icon
                    :class="data.value ? 'text-success' : 'text-danger'"
                    :name="data.value ? 'check' : 'times'"
                  ></icon>
                </template>
                <template slot="list_of_entries" slot-scope="data">
                  <b-link v-for="(entry,index) in data.value" :key="index" href="#">
                    <icon name="eye"></icon>
                    {{ entry }}
                  </b-link>
                  <br />
                </template>
                <template slot="action" slot-scope="row">
                  <b-button
                    pill
                    block
                    @click="annotate(row.item)"
                  >{{ row.item.present_in_svip_data == true ? 'Edit' : 'Create' }}</b-button>
                </template>
              </b-table>
            </b-container>
          </b-card>
          <b-card
            v-if="selected==2"
            no-body
            header="1 - Search literature via a text mining tool"
            header-bg-variant="success"
            header-text-variant="white"
          ></b-card>
          <b-card
            v-if="selected==3"
            no-body
            header="1 - Select a prediction tool"
            header-bg-variant="success"
            header-text-variant="white"
          ></b-card>
        </transition>
        <br />
        <transition name="slide-fade">
          <b-card
            v-if="show && selected == 1"
            :header="`Annotation for ${form.reference}`"
            header-bg-variant="success"
            header-text-variant="white"
          >
            <b-container fluid>
              <div>
                <b-form-group
                  label-cols-sm="4"
                  label-cols-lg="3"
                  label="Confirm or change the disease"
                  label-for="disease"
                >
                  <b-form-input
                    id="disease"
                    v-model="form.disease"
                    list="list-disease"
                    type="text"
                    placeholder="For which disease ?"
                  ></b-form-input>
                  <datalist id="list-disease">
                    <option>Lung adenocarcinoma</option>
                  </datalist>
                </b-form-group>
              </div>
              <transition name="slide-fade">
                <div v-show="form.disease != ''">
                  <b-form-group
                    label-cols-sm="4"
                    label-cols-lg="3"
                    label="Enter a drug name here"
                    label-for="drugs"
                  >
                    <b-form-input
                      id="type_of_evidence"
                      v-model="form.type_of_evidence"
                      list="list-type_of_evidence"
                      type="text"
                      placeholder="For which type of evidence ?"
                      autofocus
                    ></b-form-input>
                    <datalist id="list-type_of_evidence">
                      <option>Predictive / Therapeutic</option>
                    </datalist>
                  </b-form-group>
                </div>
              </transition>
              <transition name="slide-fade">
                <div v-show="form.disease != '' && form.type_of_evidence != ''">
                  <b-form-group
                    label-cols-sm="4"
                    label-cols-lg="3"
                    label="Enter a drug name here"
                    label-for="drugs"
                  >
                    <b-form-input id="drugs" v-model="form.drugs" autofocus></b-form-input>
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
                      :options="['Sensitive / responsive','Resistant','Reduced sensitivity','Not responsive','Adverse response','Other']"
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
                      :options="['FDA approved therapy (Tier IA)', 'Therapy included in Professional Guidelines such as NCCN or CAP (Tier IA)', 'Well-powered study with consensus from expoerts in the field (Tier IB)', 'FDA approved therapy for a different tumor type (Tier IIC)', 'Small published stufy with some consensus (Tier IIC)', 'Population study (Tier IID)', 'Clinical trial (Tier IID)', 'Pre-clinical trial (Tier IID)', 'Cases report (Tier IID)', 'Reported evidence supportive of begnin/likely begnin effect (Tier IV)', 'Other criteria']"
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
                    ></b-form-select>
                  </b-form-group>
                  <b-form-group
                    label-cols-sm="4"
                    label-cols-lg="3"
                    label="Complementary information (viewed by others)"
                    label-for="summary"
                  >
                    <b-form-textarea id="summary" v-model="form.summary" rows="3" max-rows="5"></b-form-textarea>
                  </b-form-group>
                  <b-form-group
                    label-cols-sm="4"
                    label-cols-lg="3"
                    label="Complementary information (viewed by others)"
                    label-for="comment"
                  >
                    <b-form-textarea id="comment" rows="3" max-rows="5"></b-form-textarea>
                  </b-form-group>
                  <b-button pill block variant="outline-success">Save</b-button>
                  <b-button pill block variant="success">Validate</b-button>
                </div>
              </transition>
            </b-container>
          </b-card>
        </transition>
      </b-col>
    </b-row>
  </div>
</template>
<script>
import { mapGetters } from "vuex";
import variantInformations from "@/components/genes/variants/VariantInformations";
import fields from "./ViewVariant/fields.json";
import store from "@/store";

export default {
  name: "AnnotateVariant",
  components: {
    variantInformations
  },
  data() {
    return {
      fields,
      selected: 1,
      source: "PMID",
      reference: "",
      options: [
        { value: null, text: "Please select an option" },
        { value: "PMID", text: "PMID" },
        { value: "NCT", text: "NCT Number" }
      ],
      checkItems: [],
      items: [
        {
          reference: "23816960",
          present_in_svip_data: true,
          list_of_variants: ["EGFR-L838V"],
          source: "PMID"
        },
        {
          reference: "22816960",
          present_in_svip_data: false,
          list_of_variants: [],
          source: "PMID"
        }
      ],
      show: false,
      step: 1,
      form: {
        reference: null,
        disease: "",
        type_of_evidence: "",
        drugs: [],
        effect: null,
        tier_criteria: null,
        origin: null,
        support: null,
        summary: null,
        comment: null
      }
    };
  },
  computed: {
    ...mapGetters({
      variant: "variant",
      gene: "gene"
    })
  },
  methods: {
    addEntry() {
      this.items.push({
        reference: this.reference,
        present_in_svip_data: false,
        list_of_entries: []
      });
    },
    checkEntry() {
      this.checkItems.push({
        reference: `${this.source}:${this.reference}`,
        title: "Ceci est un titre",
        authors: "Ceci est une liste d'auteurs"
      });
    },
    annotate(item) {
      var v = this;
      this.show = false;
      setTimeout(function() {
        v.form.reference = item.source + ":" + item.reference;
        v.show = true;
      }, 300);
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
