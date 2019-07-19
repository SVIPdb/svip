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
    <!-- ON REQUEST - CARD -->
    <b-card class="shadow-sm mb-3" align="left" no-body>
      <b-card-header class="p-1" header-bg-variant="danger" header-text-variant="white">
        <div class="d-flex justify-content-between">
          <div class="p-2 font-weight-bold">
            ON REQUEST
            <b-badge pill class="bg-white text-danger">{{on_request.length}}</b-badge>
          </div>
          <div>
            <b-input-group size="sm" class="p-1">
              <b-form-input v-model="search_on_request" placeholder="Type to Search"></b-form-input>
              <b-input-group-append>
                <b-button variant="light" size="sm" @click="search_on_request = ''">Clear</b-button>
              </b-input-group-append>
            </b-input-group>
          </div>
        </div>
      </b-card-header>
      <b-card-body class="p-0">
        <b-table
          small
          class="mb-0"
          :items="on_request"
          :fields="fields_on_request"
          hover
          :filter="search_on_request"
          sort-by="deadline"
          :sort-desc="true"
          show-empty
        >
          <template slot="flag" slot-scope="row">
            <icon name="flag" :class="setFlagClass(row.item.days_left)"></icon>
          </template>
          <template slot="gene_name" slot-scope="data">
            <p class="font-weight-bold">{{data.value}}</p>
          </template>
          <template slot="hgvs" slot-scope="data">
            <p class="text-monospace">{{data.value}}</p>
          </template>
          <template
            slot="deadline"
            slot-scope="row"
          >{{row.item.deadline}} ({{row.item.days_left}} days)</template>
          <template slot="curated" slot-scope="data">
            <b-badge variant="danger">{{data.value}}</b-badge>
          </template>
          <template slot="action">
            <b-button size="sm">VIEW</b-button>
          </template>
        </b-table>
      </b-card-body>
    </b-card>
    <!-- TO BE CURATED - CARD -->
    <b-card class="shadow-sm mb-3" align="left" no-body>
      <b-card-header class="p-1" header-bg-variant="info" header-text-variant="white">
        <div class="d-flex justify-content-between">
          <div class="p-2 font-weight-bold">
            TO BE CURATED
            <b-badge pill class="bg-white text-dark">{{to_be_curated.length}}</b-badge>
          </div>
          <div>
            <b-input-group size="sm" class="p-1">
              <b-form-input v-model="search_to_be_curated" placeholder="Type to Search"></b-form-input>
              <b-input-group-append>
                <b-button variant="light" size="sm" @click="search_on_request = ''">Clear</b-button>
              </b-input-group-append>
            </b-input-group>
          </div>
        </div>
      </b-card-header>
      <b-card-body class="p-0">
        <b-table
          small
          class="mb-0"
          :items="to_be_curated"
          :fields="fields_to_be_curated"
          hover
          :filter="search_to_be_curated"
          sort-by="deadline"
          :sort-desc="true"
          show-empty
        >
          <template slot="gene_name" slot-scope="data">
            <p class="font-weight-bold">{{data.value}}</p>
          </template>
          <template slot="flag" slot-scope="row">
            <icon name="flag" :class="setFlagClass(row.item.days_left)"></icon>
          </template>
          <template slot="hgvs" slot-scope="data">
            <p class="text-monospace">{{data.value}}</p>
          </template>
          <template slot="curated" slot-scope="data">
            <b-badge :variant="data.value=='Complete' ? 'success' : 'info'">{{data.value}}</b-badge>
          </template>
          <template
            slot="deadline"
            slot-scope="row"
          >{{row.item.deadline}} ({{row.item.days_left}} days)</template>
          <template slot="action">
            <b-button size="sm">VIEW</b-button>
          </template>
        </b-table>
      </b-card-body>
    </b-card>
    <!-- UNDER REVISION - CARD -->
    <b-card class="shadow-sm mb-3" align="left" no-body>
      <b-card-header class="p-1" header-bg-variant="dark" header-text-variant="white">
        <div class="d-flex justify-content-between">
          <div class="font-weight-bold p-2">
            UNDER REVISION
            <b-badge pill class="bg-white text-info">{{under_revision.length}}</b-badge>
          </div>
          <div>
            <b-input-group size="sm" class="p-1">
              <b-form-input v-model="search_under_revision" placeholder="Type to Search"></b-form-input>
              <b-input-group-append>
                <b-button variant="light" size="sm" @click="search_under_revision = ''">Clear</b-button>
              </b-input-group-append>
            </b-input-group>
          </div>
        </div>
      </b-card-header>
      <b-card-body class="p-0">
        <b-table
          small
          class="mb-0"
          :items="under_revision"
          :fields="fields_under_revision"
          hover
          :filter="search_under_revision"
          sort-by="deadline"
          :sort-desc="true"
          show-empty
        >
          <template slot="gene_name" slot-scope="data">
            <p class="font-weight-bold">{{data.value}}</p>
          </template>
          <template slot="flag" slot-scope="row">
            <icon name="flag" :class="setFlagClass(row.item.days_left)"></icon>
          </template>
          <template slot="hgvs" slot-scope="data">
            <p class="text-monospace">{{data.value}}</p>
          </template>
          <template
            slot="deadline"
            slot-scope="row"
          >{{row.item.deadline}} ({{row.item.days_left}} days)</template>
          <template slot="reviewed" slot-scope="data">
            <b-img
              v-for="(reviewer, index) in data.value"
              v-bind:key="index"
              v-b-tooltip.hover
              :title="reviewer.label"
              blank
              :blank-color="reviewer.value ? '#28a745' : '#ff5555'"
              class="mr-1"
              width="12"
              height="12"
            ></b-img>
          </template>
          <template slot="action">
            <b-button size="sm">VIEW</b-button>
          </template>
        </b-table>
      </b-card-body>
    </b-card>
  </div>
</template>

<script>
export default {
  name: "CurationDashboard",
  data() {
    return {
      search_on_request: null,
      search_to_be_curated: null,
      search_under_revision: null,
      on_request: [
        {
          curator: "curator_1",
          gene_name: "EGFR",
          variant: "T790M",
          hgvs: "NM_005228.3:c.2369C>T",
          curated: "No",
          deadline: "02.05.2019",
          days_left: 2,
          priority: "HIGH"
        }
      ],
      to_be_curated: [
        {
          curator: "curator_1",
          gene_name: "EGFR",
          variant: "L858R",
          hgvs: "NM_005228.4:c.2573T>G",
          curated: "On going",
          deadline: "12.06.2019",
          days_left: 14,
          priority: "NORMAL"
        },
        {
          curator: "curator_2",
          gene_name: "BRAF",
          variant: "G596R",
          hgvs: "NM_004333.4:c.1786G>C",
          curated: "Complete",
          deadline: "30.05.2019",
          days_left: 2,
          priority: "NORMAL"
        }
      ],
      under_revision: [
        {
          curator: "curator_1",
          gene_name: "BRAF",
          variant: "V600E",
          hgvs: "NM_004333.4:c.1799T>A",
          reviewed: [
            {
              label: "Reviewer 1",
              value: true
            },
            {
              label: "Reviewer 2",
              value: true
            },
            {
              label: "Reviewer 3",
              value: false
            }
          ],
          deadline: "30.05.2019",
          days_left: 2,
          priority: "NORMAL"
        }
      ],
      fields_on_request: [
        {
          key: "flag",
          label: "Flag",
          sortable: false
        },
        {
          key: "gene_name",
          label: "Gene name",
          sortable: true
        },
        {
          key: "variant",
          label: "Variant",
          sortable: true
        },
        {
          key: "hgvs",
          label: "HGVS.c",
          sortable: false
        },
        {
          key: "curated",
          label: "Curated",
          sortable: false
        },
        {
          key: "deadline",
          label: "Deadline (days left)",
          sortable: true
        },
        {
          key: "action",
          label: "Action",
          sortable: false
        }
      ],
      fields_to_be_curated: [
        {
          key: "flag",
          label: "Flag",
          sortable: false
        },
        {
          key: "gene_name",
          label: "Gene name",
          sortable: true
        },
        {
          key: "variant",
          label: "Variant",
          sortable: true
        },
        {
          key: "hgvs",
          label: "HGVS.c",
          sortable: false
        },
        {
          key: "curated",
          label: "Curated",
          sortable: false
        },
        {
          key: "deadline",
          label: "Deadline (days left)",
          sortable: true
        },
        {
          key: "curator",
          label: "Curator",
          sortable: true
        },
        {
          key: "action",
          label: "Action",
          sortable: false
        }
      ],
      fields_under_revision: [
        {
          key: "flag",
          label: "Flag",
          sortable: false
        },
        {
          key: "gene_name",
          label: "Gene name",
          sortable: true
        },
        {
          key: "variant",
          label: "Variant",
          sortable: true
        },
        {
          key: "hgvs",
          label: "HGVS.c",
          sortable: false
        },
        {
          key: "reviewed",
          label: "Reviewed",
          sortable: false
        },
        {
          key: "deadline",
          label: "Deadline (days left)",
          sortable: true
        },
        {
          key: "curator",
          label: "Curator",
          sortable: true
        },
        {
          key: "action",
          label: "Action",
          sortable: false
        }
      ]
    };
  },
  methods: {
    setFlagClass(days_left) {
      if (days_left <= 2) {
        return "text-danger";
      } else if (days_left <= 14) {
        return "text-warning";
      } else {
        return "text-success";
      }
    }
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
