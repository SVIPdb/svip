<template>
  <div class="col-sm-auto">
    <div class="card mt-3 top-level">
      <div class="card-header">
        <div class="card-title">SOCIBP Samples</div>
      </div>

      <div class="card-body top-level">
        <b-table :fields="fields" :items="items" :sort-by.sync="sortBy" :sort-desc="false">
          <template slot="studyName" slot-scope="row">
            <a :href="row.item.authed_link">{{ row.item.studyName }}</a>
          </template>
          <template slot="num_patients_samples" slot-scope="row">
            {{ row.item.num_patients }} / {{ row.item.num_samples }}
          </template>
        </b-table>
      </div>
    </div>
  </div>
</template>

<script>
import {HTTP} from "@/router/http";

function parameterize(params) {
  return Object.entries(params).map(([k,v]) => `${k}=${v}`).join("&");
}

export default {
  name: "SOCIBP",
  data() {
    return {
      sortBy: "",
      items: [],
      fields: [
        {
          key: "studyName",
          label: "Study",
          sortable: true
        },
        {
          key: "num_patients_samples",
          label: "# of Samples/Patients",
          sortable: true
        }
      ]
    };
  },
  mounted() {
    HTTP.get(`/socibp/stats/${this.protein}/${this.change}`).then((response) => {
      this.items = response.data.mutations.map(x => ({
        studyName: x.study.shortName,
        num_patients: x.num_patients,
        num_samples: x.num_samples,
        authed_link: x.authed_link
      }))
    })
  },
  props: {
    protein: { type: String, required: true },
    change: { type: String, required: true }
  }
};
</script>

<style scoped></style>
