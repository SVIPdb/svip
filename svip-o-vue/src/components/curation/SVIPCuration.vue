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
  <div>
    <div class="card mt-3" v-for="(disease, index) in variant.svip_data.diseases" :key="index">
      <div class="card-header bg-primary text-white">
        <div class="card-title">SVIP Curation for {{ disease.name }}</div>
      </div>

      <div class="card-body top-level">
        <b-table
          tbody-class="small"
          theader-class="small"
          small
          :fields="fields"
          :items="disease.curation_entries"
          :sort-by.sync="sortBy"
          :sort-desc="false"
        >
          <template slot="curator">vhinard</template>
          <template slot="date">27.02.2019</template>
          <template slot="actions">
            <b-button size="sm">Edit</b-button>
          </template>
        </b-table>
      </div>
    </div>
  </div>
</template>


<script>
import Vue from "vue";
import store from "@/store";

export default {
  name: "CurationSVIP",
  props: {
    variant: { type: Object, required: true }
  },
  data() {
    return {
      sortBy: "name",
      fields: [
        {
          key: "type_of_evidence",
          label: "Type of evidence",
          sortable: false
        },
        {
          key: "drug",
          label: "Drug",
          sortable: false
        },
        {
          key: "effect",
          label: "Effect",
          sortable: false
        },
        {
          key: "tier_criteria",
          label: "Tier Criteria",
          sortable: false
        },
        {
          key: "mutation_origin",
          label: "Mutation origin",
          sortable: false
        },
        {
          key: "summary",
          label: "Complementary information",
          sortable: false
        },
        {
          key: "comment",
          label: "Personal comment",
          sortable: false
        },
        {
          key: "support",
          label: "Support",
          sortable: false
        },
        {
          key: "references",
          label: "Reference",
          sortable: false
        },
        {
          key: "curator",
          label: "Curator",
          sortable: false
        },
        {
          key: "date",
          label: "Date",
          sortable: false
        },
        {
          key: "actions",
          label: "Action",
          sortable: false
        }
      ]
    };
  },
  methods: {},
  computed: {}
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
