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

  <div class="card mt-3">
    <div class="card-header">
      <div class="card-title">
        SVIP Information
        <span class="text-danger float-right">WARNING: fake data - only as a demo</span>
      </div>
    </div>

    <div class="card-body top-level">
      <b-table :fields="fields" :items="svip_entries" :sort-by.sync="sortBy" :sort-desc="false">
        <template v-slot:cell(display)="row">
          <b-link @click="row.toggleDetails">
            <icon :name="row.detailsShowing ? 'chevron-down' : 'chevron-right'"></icon>
          </b-link>
        </template>
        <template v-slot:cell(actions)="row">
          <b-button
            v-if="false"
            size="sm"
            :to="{ name: 'annotate-variant', params: { gene_id: gene, variant_id: variant.id, disease_id: row.item.id }}"
          >
            <icon name="tools"></icon>
          </b-button>
        </template>

        <template v-slot:cell(name)="row">
          <span :class="row.detailsShowing ? 'bold' : ''">{{ titleCase(row.item.name) }}</span>
        </template>

        <template v-slot:cell(age)="data">
          <age-distribution :data="data.item.age_distribution"></age-distribution>
        </template>

        <template v-slot:cell(gender)="data">
          <gender-plot :data="data.item.gender_balance"></gender-plot>
        </template>

        <template v-slot:cell(pathogenic)="data">
          <div style="vertical-align: middle; display: inline-block;">
            <span v-if="data.value">{{ data.value }}</span>
            <span v-else class="unavailable">unavailable</span>
          </div>
        </template>

        <template v-slot:cell(score)="data">
          <div style="white-space: nowrap;">
            <icon
              v-for="score in [1,2,3,4]"
              :key="score"
              :name="data.item.score < score ? 'regular/star' : 'star'"
              style="margin-right: 5px"
            />
          </div>
        </template>

        <template v-slot:cell(HEAD_actions)="row">
          <div style="text-align: right; padding-right: 5px; display: none;">
            <b-button
              size="sm"
              variant="success"
              :class="`expander-button ${isAllExpanded ? 'is-expanded' : ''}`"
              @click.stop="() => setAllExpanded(!isAllExpanded)"
            >{{ isAllExpanded ? "Collapse All" : "Expand All"}}</b-button>
          </div>
        </template>

        <template v-slot:row-details="row">
          <div class="row-details">
            <b-card no-body>
              <b-tabs
                v-model="svip_entry_tabs[row.item.name]"
                card
                :class="`svip-details-tabs selected-tab-${svip_entry_tabs[row.item.name]}`"
              >
                <b-tab title="Evidence" active>
                  <EvidenceTable :variant="variant" :row="row" />
                </b-tab>

                <b-tab title="Samples" :disabled="!(groups && groups.includes('clinicians'))">
                  <SampleTable :variant="variant" :row="row" :groups="groups" />
                </b-tab>
              </b-tabs>
            </b-card>
          </div>
        </template>
      </b-table>
    </div>

    <!--
		<div class="card-body top-level">
			<TissueDistribution :tissue_counts="variant.svip_data.tissue_counts" />
		</div>
    -->
  </div>
</template>


<script>
import Vue from "vue";
import store from "@/store";
import { titleCase } from "../../../utils";
import PubmedPopover from "@/components/widgets/PubmedPopover";

import ageDistribution from "@/components/plots/ageDistribution";
import genderPlot from "@/components/plots/genderPlot";

import { makeSampleProvider } from "./item_providers/sample_provider";
import VariomesLitPopover from "@/components/widgets/VariomesLitPopover";
import { trimPrefix } from "@/utils";
import TissueDistribution from "@/components/genes/variants/svip/TissueDistribution";
import EvidenceTable from "@/components/genes/variants/svip/EvidenceTable";
import SampleTable from "@/components/genes/variants/svip/SampleTable";

Vue.component("pass", {
  render() {
    return this.$scopedSlots.default(this.$attrs);
  }
});

export default {
  name: "VariantSVIP",
  components: { SampleTable, EvidenceTable, ageDistribution, genderPlot }, // TissueDistribution
  props: {
    variant: { type: Object, required: true }
  },
  data() {
    return {
      // we're storing the selected tab per disease so that we can manipulate the selection with the per-disease buttons
      // FIXME: (which, incidentally, aren't even being displayed right now...maybe we just remove this?)
      svip_entry_tabs: this.variant.svip_data.diseases.reduce((acc, x) => {
        // map each entry in the SVIP table by ID to a selected tab for that entry (e.g., evidence or samples)
        // by default, it'll be the first tab (evidence)
        acc[x.name] = 0;
        return acc;
      }, {}),

      svip_entries: this.variant.svip_data.diseases.map(x => ({
        _showDetails: false,
        ...x
      })),

      sortBy: "name",
      fields: [
        {
          key: "display",
          label: "",
          sortable: false
        },
        {
          key: "name",
          label: "Disease",
          sortable: true
        },
        {
          key: "nb_patients",
          label: "# of Samples",
          formatter: x => `${x}/${this.totalPatients}`,
          sortable: true,
          class: "text-center"
        },
        {
          key: "age",
          label: "Age Distribution",
          sortable: false,
          class: "text-center"
        },
        {
          key: "gender",
          label: "Gender Balance",
          sortable: false,
          class: "text-center"
        },
        {
          key: "pathogenic",
          label: "Pathogenicity",
          sortable: false
        },
        {
          key: "clinical_significance",
          label: "Clinical Significance",
          sortable: false
        },
        {
          key: "status",
          label: "Status",
          sortable: false
        },
        {
          key: "score",
          label: "SVIP Confidence",
          sortable: true,
          class: "text-center"
        },
        {
          key: "actions",
          label: "",
          sortable: false
        }
      ]
    };
  },
  methods: {
    packedFilter(filters) {
      return JSON.stringify(filters);
    },
    setAllExpanded(isExpanded) {
      this.variant.svip_data.diseases.forEach(x => {
        x._showDetails = isExpanded;
      });
    },
    titleCase
  },
  computed: {
    totalPatients() {
      return this.variant.svip_data.diseases.reduce(
        (acc, x) => acc + x.nb_patients,
        0
      );
    },
    groups() {
      return store.getters.groups;
    },
    isAllExpanded() {
      return this.variant.svip_data.diseases.every(x => x._showDetails);
    }
  }
};
</script>

<style scoped>
svg.pathogenicity_level {
  margin-left: 50px;
}

rect.pathogenicity.expert {
  fill: #118644;
}

rect.pathogenicity.automatic {
  fill: #80fe07;
}

.tab-pane.card-body {
  padding: 10px 0 0 0;
}

.paginator-holster {
  padding-left: 15px;
}

.expander-button {
  width: 100px;
  border: solid 1px #eee;
  background: #eee;
}
.expander-button.is-expanded {
  opacity: 0.5;
}
</style>

<style>
/*.svip-details-tabs .card-header {background-color: #ccc;}*/

/*.svip-details-tabs { border: solid 2px #aaa; border-radius: 5px; }*/

.svip-details-tabs.selected-tab-0 .card-header {
  background-color: #8bd4c2;
}
.svip-details-tabs.selected-tab-1 .card-header {
  background-color: #c8bcca;
}

.svip-details-tabs .card-header a.nav-link.active {
  color: black;
}
.svip-details-tabs .card-header a.nav-link {
  color: #637fb0;
}

.nav-tabs .nav-item {
  margin-right: 3px;
}
.nav-tabs .nav-item .nav-link {
  padding: 5px 20px 8px;
}
</style>
